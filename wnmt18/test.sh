#!/usr/bin/env bash

DOCKER_RUN="nvidia-docker run --init --rm -i -u $(id -u):$(id -g) -v $(pwd):/work -w /work sockeye:latest"

#docker run --init --rm -i -u $(id -u):$(id -g) -v $(pwd):/work -w /work -e MXNET_ENGINE_TYPE=NaiveEngine -e OMP_NUM_THREADS=$(($(grep -c "processor" /proc/cpuinfo) / 2)) sockeye:latest python3 -m sockeye.translate --use-cpu -m model --restrict-lexicon top_k_lexicon <data/newstest2014.en.bpe
