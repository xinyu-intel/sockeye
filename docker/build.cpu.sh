#!/usr/bin/env bash

REV=$(git rev-parse --short HEAD)
REPOSITORY="sockeye"
TAG1="${REV}-cpu"
TAG2="latest-cpu"
DOCKERFILE=$(pwd)"/docker/Dockerfile.cpu"

# Edit these as needed
MKL_VERSION="l_mkl_2018.1.163"
PYTHON_VERSION="l_python3_pu_2018.1.023"

if [ ! -e ${DOCKERFILE} ]; then
    echo "Run this from the sockeye root directory"
    exit 1
fi

if [ ! -e $(pwd)"/docker/${MKL_VERSION}.tgz" ]; then
    echo "Download Intel MKL (https://software.intel.com/en-us/mkl) to the docker directory, will look like:"
    echo "docker/${MKL_VERSION}.tgz"
    echo "Edit MKL_VERSION in this build script to match if needed."
    exit 1
fi

if [ ! -e $(pwd)"/docker/${PYTHON_VERSION}.tgz" ]; then
    echo "Download Intel Python (https://software.intel.com/en-us/distribution-for-python) to the docker directory, will look like:"
    echo "docker/${PYTHON_VERSION}.tgz"
    echo "Edit PYTHON_VERSION in this build script to match if needed."
    exit 1
fi

BUILD_ARGS="--build-arg MKL_VERSION=${MKL_VERSION} --build-arg PYTHON_VERSION=${PYTHON_VERSION} --build-arg REV=${REV}"
docker build -t ${REPOSITORY}:${TAG1} -f ${DOCKERFILE} ${BUILD_ARGS} .
docker tag ${REPOSITORY}:${TAG1} ${REPOSITORY}:${TAG2}

if [[ $? == 0 ]]; then
    echo "Build successful.  Run Sockeye with:"
    echo "docker run --rm ${REPOSITORY}:${TAG1} python3 -m sockeye.train"
    echo "or"
    echo "docker run --rm ${REPOSITORY}:${TAG2} python3 -m sockeye.train"
fi
