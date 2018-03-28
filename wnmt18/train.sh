#!/usr/bin/env bash

# Run training on GPUs
DOCKER_RUN="nvidia-docker run --init --rm -i -u $(id -u):$(id -g) -v $(pwd):/work -w /work sockeye:gpu-latest"

# Change this for contrastive training runs
MODEL_OUT="model.baseline"

# Change based on your environment
# Negative indicates "attempt to lock this many GPUs"
NUM_GPUS="-1"

# Run Sockeye training with settings from https://arxiv.org/abs/1712.05690
$DOCKER_RUN python3 -m sockeye.train \
  -s data/train.en.bpe \
  -t data/train.de.bpe \
  -vs data/newstest2013.en.bpe \
  -vt data/newstest2013.de.bpe \
  -o $MODEL_OUT \
  --seed=1 \
  --batch-type=word \
  --batch-size=8192 \
  --checkpoint-frequency=4000 \
  --device-ids=$NUM_GPUS \
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
  --learning-rate-reduce-factor=0.7 \
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
mv $MODEL_OUT/params.best $MODEL_OUT/params.single.best
$DOCKER_RUN python3 -m sockeye.average \
  -n 8 \
  --output $MODEL_OUT/params.best \
  --strategy best \
  $model
