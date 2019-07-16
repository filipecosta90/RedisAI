
.PHONY: build pack publish

VERSION=1.1.0

S3_URL=redismodules/pytorch

IID_FILE=libtorch-cpu-linux-arm64v8:$(VERSION).iid

build:
	@docker build --iidfile $(IID_FILE) -t redisfab/libtorch-cpu-linux-arm32v7:$(VERSION) -f Dockerfile --build-arg ARCH=arm32v7 ../..
	@docker build --iidfile $(IID_FILE) -t redisfab/libtorch-cpu-linux-arm64v8:$(VERSION) -f Dockerfile --build-arg ARCH=arm64v8  ../..

pack:
	@docker cp `cat $(IID_FILE)`:/build/libtorch-cpu-linux-arm-$(VERSION).tar.gz .
	@docker cp `cat $(IID_FILE)`:/build/libtorch-cpu-linux-arm64-$(VERSION).tar.gz .

publish:
	@aws s3 cp libtorch-cpu-linux-arm-$(VERSION).tar.gz s3://$(S3_URL)/ --acl public-read
	@aws s3 cp libtorch-cpu-linux-arm64-$(VERSION).tar.gz s3://$(S3_URL)/ --acl public-read
