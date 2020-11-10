#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf valid_lowisbet valid_lowisbet_?.log
mkdir -p valid_lowisbet

extra_opts="--no-shuffle --seed 1111 --maxi-batch 1 --maxi-batch-sort none"
extra_opts="$extra_opts --dim-emb 64 --dim-rnn 128 --mini-batch 32"
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"


# Files for the validation sets are swapped intentionally
$MRT_MARIAN/marian $extra_opts \
    -m valid_lowisbet/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --valid-freq 30 --after-batches 160 --early-stopping 2 \
    --valid-metrics cross-entropy --valid-sets $MRT_DATA/europarl.de-en/toy.bpe.{de,en} --valid-mini-batch 64 \
    --valid-log valid_lowisbet_1.log

test -e valid_lowisbet/model.npz
test -e valid_lowisbet/model.npz.yml
test -e valid_lowisbet_1.log

cp valid_lowisbet/model.npz.progress.yml valid_lowisbet/model.npz.progress.yml.bac
cat valid_lowisbet_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "cross-entropy" > valid_lowisbet.out

# Files for the validation sets are swapped intentionally
$MRT_MARIAN/marian $extra_opts \
    -m valid_lowisbet/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --valid-freq 30 --after-batches 320 --early-stopping 4 \
    --valid-metrics cross-entropy --valid-sets $MRT_DATA/europarl.de-en/toy.bpe.{de,en} --valid-mini-batch 64 \
    --valid-log valid_lowisbet_2.log

test -e valid_lowisbet/model.npz
test -e valid_lowisbet_2.log

cat valid_lowisbet_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "cross-entropy" >> valid_lowisbet.out
$MRT_TOOLS/diff-nums.py -p 0.1 valid_lowisbet.out valid_lowisbet.expected -o valid_lowisbet.diff

# Exit with success code
exit 0
