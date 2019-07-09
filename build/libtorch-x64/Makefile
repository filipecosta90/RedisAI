
.PHONY: repack upload

VERSION=1.1.0

S3_URL=redismodules/pytorch

repack:
	@PT_VERSION=$(VERSION) ./repack.sh

upload:
	@aws s3 cp libtorch-cpu-linux-x86_64-$(VERSION).tar.gz s3://$(S3_URL)/ --acl public-read
