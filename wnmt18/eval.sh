#!/usr/bin/env bash

# Change to match model name in train.sh:
MODEL="baseline"
# Change for contrastive runs with the same model:
RUN="default"

# CLI args for cpu, gpu, or both
if [[ ${#} < 1 ]]; then
  echo "Usage: ${0} [cpu] [gpu]"
  exit 2
fi

mkdir -p results

for DEVICE in ${@}; do
  # Choose optimal settings for CPU or GPU
  # Change args here to affect both eval and run scripts
  if [[ ${DEVICE} == "cpu" ]]; then
    DOCKER_RUN="docker run --init --rm -i -u $(id -u):$(id -g) -v $(readlink -f ${MODEL}):/model -v $(pwd):/work -w /work sockeye:latest-cpu"
    DEVICE_ARGS="--use-cpu"
    BATCH_SIZE=1
    CHUNK_SIZE=1
    RESTRICT_ARGS="--restrict-lexicon=/model/top_k_lexicon"
  elif [[ ${DEVICE} == "gpu" ]]; then
    DOCKER_RUN="docker run --runtime=nvidia --init --rm -i -u $(id -u):$(id -g) -v $(readlink -f ${MODEL}):/model -v $(pwd):/work -w /work sockeye:latest-gpu"
    DEVICE_ARGS=""
    BATCH_SIZE=32
    CHUNK_SIZE=1000
    RESTRICT_ARGS=""
  else
    continue
  fi
  # Create translate command and WNMT18 run script
  # Change args here to affect both eval and run scripts
  TRANSLATE="python3 -m sockeye.translate \
--models=/model \
--beam-size=5 \
--batch-size=${BATCH_SIZE} \
--chunk-size=${CHUNK_SIZE} \
--length-penalty-alpha=0.1 \
--length-penalty-beta=0.0 \
--max-output-length-num-stds=2 \
--bucket-width=10 \
${DEVICE_ARGS} \
${RESTRICT_ARGS}"
  echo "zcat -f \$1 |apply_bpe.py -c /model/codes |${TRANSLATE} |sed -u -r 's/@@( |\$)//g' >\$2" \
    >results/${MODEL}.${RUN}.${DEVICE}.run.sh
  # Decode both test sets
  for SET in newstest2014 newstest2015; do
    # BPE encode -> decode -> BPE join
    zcat -f data/${SET}.en \
      |${DOCKER_RUN} apply_bpe.py -c /model/codes \
      |${DOCKER_RUN} ${TRANSLATE} \
        2> >(tee -a results/${SET}.${MODEL}.${RUN}.${DEVICE}.log >&2) \
      |sed -u -r 's/@@( |$)//g' \
      >results/${SET}.${MODEL}.${RUN}.${DEVICE}
    # Run MultEval
    ${DOCKER_RUN} multeval.sh eval \
      --hyps-baseline results/${SET}.${MODEL}.${RUN}.${DEVICE} \
      --refs data/${SET}.de \
      --meteor.language de \
      >results/${SET}.${MODEL}.${RUN}.${DEVICE}.scores
  done
done
