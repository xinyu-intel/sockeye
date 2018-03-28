#!/usr/bin/env bash

REV=$(git rev-parse --short HEAD)
REPOSITORY="sockeye"
TAG1="${REV}-cpu"
TAG2="latest-cpu"
DOCKERFILE=$(pwd)"/docker/Dockerfile.cpu"

if [ ! -e ${DOCKERFILE} ]; then
    echo "Run this from the sockeye root directory"
    exit 1
fi

BUILD_ARGS="--build-arg REV=${REV}"
docker build -t ${REPOSITORY}:${TAG1} -f ${DOCKERFILE} ${BUILD_ARGS} .
docker tag ${REPOSITORY}:${TAG1} ${REPOSITORY}:${TAG2}

if [[ $? == 0 ]]; then
    echo "Build successful.  Run Sockeye with:"
    echo "docker run --rm ${REPOSITORY}:${TAG1} python3 -m sockeye.train"
    echo "or"
    echo "docker run --rm ${REPOSITORY}:${TAG2} python3 -m sockeye.train"
fi
