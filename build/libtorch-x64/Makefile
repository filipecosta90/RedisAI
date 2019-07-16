
.PHONY: build pack repack publish

VERSION=1.1.0

STEM=libtorch-cpu-linux-x86_64-$(VERSION)

S3_URL=redismodules/pytorch

IID_FILE=libtorch-cpu-linux-x64:$(VERSION).iid

build:
	@docker build --iidfile $(IID_FILE) -t redisfab/libtorch-cpu-linux-x64:$(VERSION) -f Dockerfile ../.. 

pack:
	@docker cp `cat $(IID_FILE)`:/build/libtorch-cpu-linux-x64-$(VERSION).tar.gz .

repack:
	@PT_VERSION=$(VERSION) ./repack.sh

publish:
	@aws s3 cp libtorch-cpu-linux-x86_64-$(VERSION).tar.gz s3://$(S3_URL)/ --acl public-read
