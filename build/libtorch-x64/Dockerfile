ARG OS=ubuntu:bionic

#----------------------------------------------------------------------------------------------
FROM ${OS}

ARG PT_VER=v1.0.1

RUN set -ex; apt-get update; apt-get install -y git

WORKDIR /build

RUN apt-get install -y build-essential
RUN apt-get install -y python3-pip  python3-cffi
RUN apt-get install -y ninja-build cmake
RUN pip3 install setuptools pyyaml typing
RUN pip3 install numpy mkl mkl-include

RUN git clone https://github.com/pytorch/pytorch.git ;\
        cd pytorch ;\
        git checkout ${PT_VER}

RUN cd pytorch ;\
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
