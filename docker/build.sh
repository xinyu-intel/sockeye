#!/usr/bin/env bash

# CLI args for cpu, gpu, or both
if [[ ${#} < 1 ]]; then
  echo "Usage: ${0} [cpu] [gpu]"
  exit 2
fi

REPOSITORY="sockeye"
REV=$(git rev-parse --short HEAD)

for DEVICE in ${@}; do
  # Choose settings for CPU or GPU
  if [[ ${DEVICE} == "cpu" ]]; then
    TAG1="${REV}-cpu"
    TAG2="latest-cpu"
    DOCKERFILE=$(pwd)"/docker/Dockerfile.cpu"
    RUN="run"
  elif [[ ${DEVICE} == "gpu" ]]; then
    TAG1="${REV}-gpu"
    TAG2="latest-gpu"
    DOCKERFILE=$(pwd)"/docker/Dockerfile.gpu"
    RUN="run --runtime=nvidia"
  else
    continue
  fi
  # Build files present?
  if [ ! -e ${DOCKERFILE} ]; then
    echo "Run this from the sockeye root directory"
    exit 1
  fi
  # Build image
  BUILD_ARGS="--build-arg REV=${REV}"
  docker build -t ${REPOSITORY}:${TAG1} -f ${DOCKERFILE} ${BUILD_ARGS} .
  docker tag ${REPOSITORY}:${TAG1} ${REPOSITORY}:${TAG2}
  if [[ $? == 0 ]]; then
      echo "Build successful.  Run Sockeye with:"
      echo "docker ${RUN} --rm ${REPOSITORY}:${TAG1} python3 -m sockeye.train"
      echo "or"
      echo "docker ${RUN} --rm ${REPOSITORY}:${TAG2} python3 -m sockeye.train"
  fi
done
