#!/usr/bin/env bash

# Modify the following as needed
DEVICE="cpu"
#DEVICE="gpu"

if [[ ${DEVICE} == "cpu" ]]; then
  BATCH_SIZE=1
  CHUNK_SIZE=1
  DEVICE_ARGS="--use-cpu"
else
  BATCH_SIZE=16
  CHUNK_SIZE=1000
  DEVICE_ARGS=""
fi

INPUT=${1}
OUTPUT=${2}

cat ${INPUT} \
  |${DOCKER_RUN} apply_bpe.py -c codes \
  |${DOCKER_RUN} python3 -m sockeye.translate \
    --models=/model \
    --beam-size=5 \
    --batch-size=${BATCH_SIZE} \
    --chunk-size=${CHUNK_SIZE} \
    --length-penalty-alpha=0.1 \
    --length-penalty-beta=0.0 \
    --max-output-length-num-stds=2 \
    --bucket-width=10 \
    ${DEVICE_ARGS} \
    --restrict-lexicon=/model/top_k_lexicon \
  |sed -u -r 's/@@( |$)//g' \
  >${OUTPUT}
