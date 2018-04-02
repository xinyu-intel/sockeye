#!/usr/bin/env bash

# For contrastive training runs, copy and modify this script, including changing
# the model name:
MODEL="baseline"

# Change based on your environment, recommended: -2 or -4
# Negative indicates "attempt to lock this many GPUs"
NUM_GPUS="-4"

# Run training on GPUs
DOCKER_RUN="docker run --runtime=nvidia --init --rm -i -u $(id -u):$(id -g) -v $(pwd):/work -w /work sockeye:latest-gpu"

# Run Sockeye training with settings similar to https://arxiv.org/abs/1712.05690
${DOCKER_RUN} python3 -m sockeye.train \
  -s data/train.en.bpe \
  -t data/train.de.bpe \
  -vs data/newstest2013.en.bpe \
  -vt data/newstest2013.de.bpe \
  -o ${MODEL} \
  --seed=1 \
  --batch-type=word \
  --batch-size=8192 \
  --checkpoint-frequency=2000 \
  --device-ids=${NUM_GPUS} \
  --embed-dropout=0:0 \
  --encoder=transformer \
  --decoder=transformer \
  --num-layers=6:6 \
  --transformer-model-size=512 \
  --transformer-attention-heads=8 \
  --transformer-feed-forward-num-hidden=2048 \
  --transformer-preprocess=n \
  --transformer-postprocess=dr \
  --transformer-dropout-attention=0.1 \
  --transformer-dropout-act=0.1 \
  --transformer-dropout-prepost=0.1 \
  --transformer-positional-embedding-type=fixed \
  --loss=cross-entropy \
  --loss-normalization-type=valid \
  --label-smoothing=0.1 \
  --weight-tying \
  --weight-tying-type=src_trg_softmax \
  --weight-init=xavier \
  --weight-init-scale=3.0 \
  --weight-init-xavier-factor-type=avg \
  --embed-weight-init=default \
  --num-embed=512:512 \
  --optimizer=adam \
  --optimized-metric=perplexity \
  --gradient-clipping-threshold=-1 \
  --gradient-clipping-type=abs \
  --initial-learning-rate=0.0002 \
  --learning-rate-reduce-num-not-improved=8 \
  --learning-rate-reduce-factor=0.9 \
  --learning-rate-scheduler-type=plateau-reduce \
  --learning-rate-warmup=0 \
  --learning-rate-decay-optimizer-states-reset=best \
  --learning-rate-decay-param-reset \
  --max-num-checkpoint-not-improved=32 \
  --min-num-epochs=1 \
  --decode-and-evaluate=500 \
  --keep-last-params=60 \
  --lock-dir /var/lock \
  --use-tensorboard

# Average parameters from the best checkpoints
cp ${MODEL}/params.best ${MODEL}/params.single.best
${DOCKER_RUN} python3 -m sockeye.average \
  -n 8 \
  --output=${MODEL}/params.best \
  --strategy=best \
  ${MODEL}

# Generate Top-K lexicon for vocabulary selection
${DOCKER_RUN} python3 -m sockeye.lexicon \
  -m ${MODEL} \
  -i lex_table \
  -o ${MODEL}/top_k_lexicon \
  -k 200

# Copy BPE codes for sub-word encoding
cp codes ${MODEL}/codes

# Cleanup
rm ${MODEL}/decode.output.*
rm ${MODEL}/params.0*
