ARG ARCH=x64

#----------------------------------------------------------------------------------------------
FROM insready/bazel:latest as bazel
FROM ${OS}

ARG OS=ubuntu:bionic
ARG TF_VER=v1.13.1

ENV X_NPROC "cat /proc/cpuinfo|grep processor|wc -l"

RUN set -ex; apt-get update; apt-get install -y git

WORKDIR /build

COPY --from=bazel /usr/bin/bazel* /usr/local/bin/

RUN apt-get install -y build-essential
RUN apt-get install -y python3-dev python3-pip

RUN pip install six numpy wheel setuptools mock
RUN pip install keras_applications==1.0.6 --no-deps
RUN pip install keras_preprocessing==1.0.5 --no-deps

RUN git clone https://github.com/tensorflow/tensorflow.git ;\
	cd tensorflow ;\
	git checkout ${TF_VER}

RUN apt-get install -y python3 python3-dev

RUN cd tensorflow ;\
	./configure ;\
	bazel build --jobs $(eval "$X_NPROC") --config=opt //tensorflow:libtensorflow.so
