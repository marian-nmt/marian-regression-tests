#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf final_epoch final_epoch.log vocab.*.yml
mkdir -p final_epoch

head -n 3000 $MRT_DATA/europarl.de-en/corpus.bpe.en > train.bpe.en
head -n 3000 $MRT_DATA/europarl.de-en/corpus.bpe.de > train.bpe.de

$MRT_MARIAN/build/marian \
    --no-shuffle --seed 1111 \
    -m final_epoch/model.npz \
    -t train.bpe.en train.bpe.de \
    -v vocab.en.yml vocab.de.yml \
    --dim-vocabs 50000 50000 \
    --mini-batch 32 --disp-freq 20 --valid-freq 40 --after-epochs 1 \
    --valid-metrics cross-entropy \
    --valid-sets valid.bpe.en valid.bpe.de \
    --valid-log final_epoch.log

test -e final_epoch/model.npz
test -e final_epoch.log

$MRT_TOOLS/strip-timestamps.sh < final_epoch.log > final_epoch.out
$MRT_TOOLS/diff-floats.py final_epoch.out final_epoch.expected -p 0.2 > final_epoch.diff

# Exit with success code
exit 0
