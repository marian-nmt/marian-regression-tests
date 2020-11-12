#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf adam_load adam_load_?.log
mkdir -p adam_load

extra_opts="--no-shuffle --seed 7777 --maxi-batch 1 --maxi-batch-sort none --mini-batch 2 --dim-rnn 64 --dim-emb 32"
# Added because default options has changes
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"

$MRT_MARIAN/marian \
    -m adam_load/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 1 --after-batches 3 -l 0.1 $extra_opts \
    --log adam_load_1.log

test -e adam_load/model.npz
test -e adam_load/model.npz.optimizer.npz
test -e adam_load_1.log

cat adam_load_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > adam_load.out

$MRT_MARIAN/marian \
    -m adam_load/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 1 --after-batches 6 -l 0.1 $extra_opts \
    --log adam_load_2.log

test -e adam_load/model.npz
test -e adam_load/model.npz.optimizer.npz
test -e adam_load_2.log

cat adam_load_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' >> adam_load.out

# The allowed tolerance needs to be radiculously high as restarting the
# training is very instable on different GPU devices
$MRT_TOOLS/diff-nums.py -p 15.0 -n 1 adam_load.out adam_load.expected -o adam_load.diff

# Exit with success code
exit 0
