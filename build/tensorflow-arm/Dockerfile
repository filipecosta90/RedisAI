ARG ARCH=x64

#----------------------------------------------------------------------------------------------
FROM insready/bazel:latest as bazel
FROM ${OS}

ARG OS=debian:buster
ARG TF_VER=1.13.1

ENV X_NPROC "cat /proc/cpuinfo|grep processor|wc -l"

WORKDIR /build

COPY --from=bazel /usr/bin/bazel* /usr/local/bin/

RUN set -e; \
	apt-get update; \
	apt-get -qq install -y git build-essential python3 python3-dev python3-pip

RUN pip install six numpy wheel setuptools mock
RUN pip install keras_applications==1.0.6 --no-deps
RUN pip install keras_preprocessing==1.0.5 --no-deps

RUN set -e; \
	git clone https://github.com/tensorflow/tensorflow.git ;\
	cd tensorflow ;\
	git checkout v${TF_VER}

RUN set -e; \
	cd tensorflow ;\
	./configure ;\
	bazel build --jobs $(eval "$X_NPROC") --config=opt //tensorflow:libtensorflow.so
