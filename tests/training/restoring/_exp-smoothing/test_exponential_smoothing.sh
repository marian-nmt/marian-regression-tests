#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf expsmooth expsmooth_*.log
mkdir -p expsmooth

opts="--no-shuffle --seed 555 --maxi-batch 1 --maxi-batch-sort none --dim-rnn 64 --dim-emb 32 -o sgd --exponential-smoothing 0.1 --learn-rate 0.1"


$MRT_MARIAN/build/marian \
    -m expsmooth/model.full.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 $opts \
    --log expsmooth_f.log

test -e expsmooth/model.full.npz
test -e expsmooth_f.log

cat expsmooth_f.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > expsmooth.expected


$MRT_MARIAN/build/marian \
    -m expsmooth/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 50 $opts \
    --log expsmooth_1.log

test -e expsmooth/model.npz
test -e expsmooth/model.npz.mvavg.npz
test -e expsmooth_1.log

cat expsmooth_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > expsmooth.out


$MRT_MARIAN/build/marian \
    -m expsmooth/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 $opts \
    --log expsmooth_2.log

test -e expsmooth/model.npz
test -e expsmooth/model.npz.mvavg.npz
test -e expsmooth_2.log

cat expsmooth_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' >> expsmooth.out

$MRT_TOOLS/diff-floats.py -p 0.01 expsmooth.out expsmooth.expected > expsmooth.diff

# Exit with success code
exit 0
