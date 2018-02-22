#!/usr/bin/env bash

mkdir -p data

for FILE in newstest2013.de newstest2013.en newstest2014.de newstest2014.en newstest2015.de newstest2015.en train.de train.en; do
  wget -O data/${FILE} "https://nlp.stanford.edu/projects/nmt/data/wmt14.en-de/${FILE}"
done
