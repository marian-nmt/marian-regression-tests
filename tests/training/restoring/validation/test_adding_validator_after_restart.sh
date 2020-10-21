#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf valid_add valid_add_?.log
mkdir -p valid_add

extra_opts="--no-shuffle --seed 2222 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd"
extra_opts="$extra_opts --dim-emb 128 --dim-rnn 256 --mini-batch 16"
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"

#$MRT_MARIAN/marian $extra_opts \
    #-m valid_add/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    #--disp-freq 10 --valid-freq 20 --after-batches 200 --early-stopping 5 \
    #--valid-metrics cross-entropy perplexity \
    #--valid-sets dev.bpe.{en,de} --valid-mini-batch 64 \
    #--valid-log valid_add.expected.log

#cat valid_add.expected.log | $MRT_TOOLS/strip-timestamps.sh > valid_add.expected
#exit 1


$MRT_MARIAN/marian $extra_opts \
    -m valid_add/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --valid-freq 20 --after-batches 100 --early-stopping 5 \
    --valid-metrics cross-entropy \
    --valid-sets dev.bpe.{en,de} --valid-mini-batch 64 \
    --valid-log valid_add_1.log

test -e valid_add/model.npz
test -e valid_add/model.npz.yml
test -e valid_add_1.log

cp valid_add/model.npz.progress.yml valid_add/model.npz.progress.yml.bac
cat valid_add_1.log | $MRT_TOOLS/strip-timestamps.sh > valid_add.out

$MRT_MARIAN/marian $extra_opts \
    -m valid_add/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --valid-freq 20 --after-batches 200 --early-stopping 5 \
    --valid-metrics cross-entropy ce-mean-words \
    --valid-sets dev.bpe.{en,de} --valid-mini-batch 64 \
    --valid-log valid_add_2.log

test -e valid_add/model.npz
test -e valid_add_2.log

cat valid_add_2.log | $MRT_TOOLS/strip-timestamps.sh >> valid_add.out
$MRT_TOOLS/diff-nums.py -p 0.003 valid_add.out valid_add.expected -o valid_add.diff

# Exit with success code
exit 0
