#!/usr/bin/env bash

DOCKER_RUN="docker run --init --rm -i -u $(id -u):$(id -g) -v $(pwd):/work -w /work sockeye:latest-cpu"

paste data/train.en.bpe data/train.de.bpe |sed -e "s/\t/ ||| /g" >data/train.en-de.bpe

${DOCKER_RUN} fast_align -i data/train.en-de.bpe -v -d -o -p lex_table -t -1000000 >data/train.en-de.bpe.align
