
.PHONY: build pack publish

VERSION=1.1.0

S3_URL=redismodules/pytorch

build:
	@docker build -t redisfab/libtorch-arm64v8:$(VERSION) -f build/libtorch-arm/Dockerfile ../..

pack:
	@PT_VERSION=$(VERSION) ./repack.sh

publish:
	@aws s3 cp libtorch-cpu-linux-arm64v8-$(VERSION).tar.gz s3://$(S3_URL)/ --acl public-read
	@aws s3 cp libtorch-cpu-linux-arm32v7-$(VERSION).tar.gz s3://$(S3_URL)/ --acl public-read
