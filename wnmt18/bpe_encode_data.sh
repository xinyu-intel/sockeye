#!/usr/bin/env bash

DOCKER_RUN="docker run --init --rm -i -u $(id -u):$(id -g) -v $(pwd):/work -w /work sockeye:latest-cpu"

NUM_OPERATIONS="32000"

cat data/{train.en,train.de} |$DOCKER_RUN learn_bpe.py -s ${NUM_OPERATIONS} >codes

for FILE in newstest2013.de newstest2013.en newstest2014.de newstest2014.en newstest2015.de newstest2015.en train.de train.en; do
  $DOCKER_RUN apply_bpe.py -c codes <data/${FILE} >data/${FILE}.bpe
done
