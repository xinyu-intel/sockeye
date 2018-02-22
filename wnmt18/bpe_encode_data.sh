#!/usr/bin/env bash

NUM_OPERATIONS="32000"

if [ ! -e subword-nmt ]; then
  git clone https://github.com/rsennrich/subword-nmt.git
fi

cat data/{train.en,train.de} |./subword-nmt/learn_bpe.py -s ${NUM_OPERATIONS} >codes

for FILE in newstest2013.de newstest2013.en newstest2014.de newstest2014.en newstest2015.de newstest2015.en train.de train.en; do
  ./subword-nmt/apply_bpe.py -c codes <data/${FILE} >data/${FILE}.bpe
done
