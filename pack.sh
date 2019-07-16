#!/bin/bash

# arguments:
#   BRANCH: specifies branch names to serve as an exta package tag
#   INTO: package destination directory (optinal)

set -ex

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

BINDIR=$(cat $ROOT/BINDIR)
BIN=$ROOT/bin

PRODUCT=redisai
PRODUCT_LIB=$PRODUCT.so
FIXEDLIB=$BINDIR/ramp/$PRODUCT_LIB

if [[ -z $VERSION ]]; then
	GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
	GIT_COMMIT=$(git describe --always --abbrev=7 --dirty="+")
	GIT_VER="${GIT_BRANCH}-${GIT_COMMIT}"
else
	GIT_VER="$VERSION"
fi

OSX=""
BIND=""
REDIS_ENT_LIB_PATH=/opt/redislabs/lib

if [[ $(./deps/readies/bin/platform --os) == macosx ]]; then
	OSX=1
	
	export PATH=$PATH:$HOME/Library/Python/2.7/bin

	realpath() {
    	[[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
	}
fi

if ! command -v redis-server > /dev/null; then
	echo "Cannot find redis-server. Aborting."
	exit 1
fi 

[[ -z $OSX || -e $REDIS_ENT_LIB_PATH ]] || { echo "$REDIS_ENT_LIB_PATH exists - aborting."; exit 1; }

if [[ ! -e $REDIS_ENT_LIB_PATH ]]; then
	ln -fs $ROOT/deps/install/ $REDIS_ENT_LIB_PATH
else
	BIND=1
	mount --bind $ROOT/deps/install/ $REDIS_ENT_LIB_PATH
fi

export LD_LIBRARY_PATH=$ROOT/deps/install:$LD_LIBRARY_PATH
ramp pack -m ramp.yml -o "build/redisai.{os}-{architecture}.latest.zip" $REDISAI
tar -C deps/install pczf $BINDIR/redisai-dependencies.tgz  *.so* 

mkdir -p $BINDIR/ramp
cp -f $BINDIR/$PRODUCT_LIB $FIXEDLIB
patchelf --set-rpath $REDIS_ENT_LIB_PATH $FIXEDLIB

echo "Building package ..."
RAMPOUT=$(mktemp /tmp/ramp.XXXXXX)
ramp pack -m $ROOT/ramp.yml -o $(realpath $BINDIR)/$PRODUCT.{os}-{architecture}.{semantic_version}.zip $FIXEDLIB 2> /dev/null | grep '.zip' > $RAMPOUT
realpath $(tail -1 $RAMPOUT) > $BIN/PACKAGE
rm -f $RAMPOUT
PACK_FNAME=$(basename `cat $BIN/PACKAGE`)
ARCHOSVER=$(echo "$PACK_FNAME" | sed -e "s/^$PACKAGE_NAME\.\([^.]*\..*\)\.zip/\1/")
ARCHOS=$(echo "$ARCHOSVER" | cut -f1 -d.)

echo "Building dependencies ..."
cd $ROOT/deps/install
tar pczf $BINDIR/$PRODUCT-dependencies.${ARCHOSVER}.tgz *.so*
DEPS_FNAME=$PRODUCT-dependencies.${ARCHOSVER}.tgz

cd "$BINDIR"
ln -s $PACK_FNAME $PRODUCT.latest.zip
ln -s $DEPS_FNAME $PRODUCT-dependencies.latest.tgz

if [[ ! -z $BRANCH ]]; then
	ln -s $PACK_FNAME $PRODUCT.${BRANCH}.zip
	ln -s $DEPS_FNAME $PRODUCT-dependencies.${BRANCH}.tgz
fi
ln -s $PACK_FNAME $PRODUCT.${GIT_VER}.zip
ln -s $DEPS_FNAME $PRODUCT-dependencies.${GIT_VER}.tgz

RELEASE_ARTIFACTS=\
	$PACK_FNAME $DEPS_FNAME \
	$PRODUCT.latest.zip $PRODUCT-dependencies.latest.tgz

DEV_ARTIFACTS=\
	$PRODUCT.${BRANCH}.zip $PRODUCT-dependencies.${BRANCH}.tgz \
	$PRODUCT.${GIT_VER}.zip $PRODUCT-dependencies.${GIT_VER}.tgz

if [[ ! -z $INTO ]]; then
	INTO=$(realpath $INTO)
	mkdir -p $INTO/release $INTO/branch
	cd $INTO/release
	foreach f in ($RELEASE_ARTIFACTS)
		ln -s $f
	end
	
	cd $INTO/branch
	foreach f in ($DEV_ARTIFACTS)
		ln -s $f
	end
fi

if [[ -z $BIND ]]; then
	rm $REDIS_ENT_LIB_PATH
else
	umount $REDIS_ENT_LIB_PATH
fi

echo "Done."
