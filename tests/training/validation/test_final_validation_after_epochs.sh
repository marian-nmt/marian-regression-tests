#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf final_epoch final_epoch.log vocab.small.*.yml
mkdir -p final_epoch

test -e train.bpe.en || head -n 3000 $MRT_DATA/europarl.de-en/corpus.bpe.en > train.bpe.en
test -e train.bpe.de || head -n 3000 $MRT_DATA/europarl.de-en/corpus.bpe.de > train.bpe.de

$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --optimizer sgd --dim-emb 64 --dim-rnn 128 \
    -m final_epoch/model.npz -t train.bpe.{en,de} \
    -v vocab.small.en.yml vocab.small.de.yml --dim-vocabs 50000 50000 \
    --mini-batch 32 --disp-freq 20 --valid-freq 40 --after-epochs 1 \
    --valid-metrics cross-entropy --valid-sets valid.bpe.{en,de} \
    --valid-log final_epoch.log

test -e final_epoch/model.npz
test -e final_epoch.log

$MRT_TOOLS/strip-timestamps.sh < final_epoch.log > final_epoch.out
$MRT_TOOLS/diff-nums.py final_epoch.out final_epoch.expected -p 0.9 -o final_epoch.diff

# Exit with success code
exit 0
