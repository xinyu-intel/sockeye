# This Dockerfile will build a nvidia-docker compatible Sockeye image that uses
# CUDA, MKL, and Intel Python for top performance on GPUs and CPUs.

# Nvidia's pre-built Ubuntu image with CUDA
FROM nvidia/cuda:9.0-cudnn7-devel-ubuntu16.04

# CUDA stubs to support use with vanilla docker when not using GPU functionality
RUN cd /usr/local/cuda/lib64/stubs && \
    ln -s libcuda.so libcuda.so.1
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/usr/local/cuda/lib64/stubs

# UTF-8 default encoding
RUN apt-get update && apt-get install -y locales
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# System packages
RUN apt-get update && apt-get install -y \
    cmake \
    cpio \
    git \
    libgoogle-perftools-dev \
    libsparsehash-dev \
    libunwind-dev \
    pkg-config \
    wget

# Local installs
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/usr/local/lib
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/usr/local/lib64

# MKL
ARG MKL_VERSION
COPY docker/${MKL_VERSION}.tgz /opt/${MKL_VERSION}.tgz
RUN cd /opt && \
    tar xf ${MKL_VERSION}.tgz && \
    cd ${MKL_VERSION} && \
    sed -i -e "s/ACCEPT_EULA=decline/ACCEPT_EULA=accept/g" silent.cfg && \
    bash install.sh -s silent.cfg
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:/opt/intel/compilers_and_libraries_2018.1.163/linux/compiler/lib/intel64_lin

# Intel Python3
ARG PYTHON_VERSION
COPY docker/${PYTHON_VERSION}.tgz /opt/${PYTHON_VERSION}.tgz
RUN cd /opt && \
    tar xf ${PYTHON_VERSION}.tgz && \
    cd ${PYTHON_VERSION} && \
    sed -i -e "s/ACCEPT_EULA=decline/ACCEPT_EULA=accept/g" silent.cfg && \
    bash install.sh -s silent.cfg && \
    rm -rf /opt/${PYTHON_VERSION}.tgz /opt/${PYTHON_VERSION}
ENV PATH ${PATH}:/opt/intel/intelpython3/bin
ENV PKG_CONFIG_PATH ${PKG_CONFIG_PATH}:/opt/intel/intelpython3/lib/pkgconfig
ENV LD_LIBRARY_PATH $${LD_LIBRARY_PATH}:/opt/intel/intelpython3/lib

# MXNet Python package with CUDA, CUDNN, and MKL
ENV MXNET_VERSION apache-mxnet-src-1.1.0-incubating
ENV MXNET_URL https://github.com/apache/incubator-mxnet/releases/download/1.1.0/apache-mxnet-src-1.1.0-incubating.tar.gz
RUN cd /opt && \
    wget ${MXNET_URL} && \
    tar xf ${MXNET_VERSION}.tar.gz && \
    cd ${MXNET_VERSION} && \
    make USE_BLAS=mkl USE_INTEL_PATH=/opt/intel USE_CUDA=1 USE_CUDA_PATH=/usr/local/cuda USE_CUDNN=1 -j $(grep -c "processor" /proc/cpuinfo)
RUN cd /opt/${MXNET_VERSION}/python && \
    python3 setup.py build install

# Additional Sockeye Python dependencies
RUN pip install \
    pyyaml \
    tensorboard==1.0.0a6 \
    typing

# fast_align
ENV FAST_ALIGN_VERSION 7c2bbca3d5d61ba4b0f634f098c4fcf63c1373e1
RUN cd /opt && \
    git clone https://github.com/clab/fast_align.git && \
    cd fast_align && \
    git checkout ${FAST_ALIGN_VERSION} && \
    mkdir build && \
    cd build && \
    cmake .. && \
    make -j
ENV PATH ${PATH}:/opt/fast_align/build

# This revision of Sockeye
ARG REV
RUN mkdir -p /opt/sockeye/__sockeye_tmp_build_dir
RUN echo "${REV}" > /opt/sockeye/rev
COPY contrib/ /opt/sockeye/contrib/
COPY docs/ /opt/sockeye/docs/
COPY sockeye/ /opt/sockeye/sockeye/
COPY test/ /opt/sockeye/test/
COPY \
    CHANGELOG.md \
    LICENSE \
    MANIFEST.in \
    NOTICE \
    README.md \
    requirements.dev.txt \
    requirements.txt \
    setup.cfg \
    setup.py \
    /opt/sockeye/
RUN cd /opt/sockeye && \
    python3 setup.py bdist_wheel -d __sockeye_tmp_build_dir && \
    pip install __sockeye_tmp_build_dir/*.whl --no-deps
