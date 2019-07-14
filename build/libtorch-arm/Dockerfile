# BUILD redisfab/libtorch-${ARCH}:$(PT_VER)

# stretch|bionic|buster
ARG OSNICK=buster

# arm32v7|arm64v8
ARG ARCH=arm64v8

ARG PT_VER=1.1.0

#----------------------------------------------------------------------------------------------
FROM redisfab/${ARCH}-xbuild:${OSNICK} as builder

RUN [ "cross-build-start" ] 

WORKDIR /build

RUN set -e ;\
	apt-get -qq update ;\
	apt-get -qq install -y git build-essential ninja-build cmake python3-pip python3-cffi
RUN pip3 install setuptools pyyaml typing numpy
# mkl mkl-include

RUN set -e ;\
	git clone https://github.com/pytorch/pytorch.git ;\
	cd pytorch ;\
	git checkout v${PT_VER} ;\
	git submodule update --init --recursive

RUN set -e ;\
	cd pytorch ;\
	BUILD_PYTHON=0 \
	USE_GLOO=1 \
	USE_OPENCV=0 \
	BUILD_TORCH=ON \
	BUILD_BINARY=ON \
	BUILD_CAFFE2_OPS=ON \
	NO_CUDA=1 \
	NO_DISTRIBUTED=1 \
	NO_MKLDNN=1 \
	NO_NNPACK=1 \
	NO_QNNPACK=1 \
	python3 setup.py install

ADD ./deps/readies/ /build/deps/readies/
ADD ./build/libtorch-arm/collect.py /build/

RUN  ./collect.py

RUN [ "cross-build-end" ]
