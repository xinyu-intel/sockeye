#!/usr/bin/env bash

# CLI args for cpu, gpu, or both
if [[ ${#} != 5 ]]; then
  echo "Usage: ${0} sockeye:tag model run.sh team-name system-name"
  echo "Ex:    ${0} sockeye:latest-cpu baseline results/baseline.default.cpu.run.sh my-team baseline"
  exit 2
fi

IMAGE=${1}
MODEL=${2}
RUN=${3}
TEAM=${4}
SYSTEM=${5}

docker run --name=translator -itd ${IMAGE}
docker cp ${MODEL} translator:/model
docker cp ${RUN} translator:/run.sh
docker commit translator wnmt2018_${TEAM}_${SYSTEM}
docker rm -f translator
