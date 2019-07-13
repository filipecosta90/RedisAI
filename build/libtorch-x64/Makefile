
.PHONY: pack publish

VERSION=1.1.0

S3_URL=redismodules/pytorch

pack:
	@PT_VERSION=$(VERSION) ./repack.sh

publish:
	@aws s3 cp libtorch-cpu-linux-x86_64-$(VERSION).tar.gz s3://$(S3_URL)/ --acl public-read
