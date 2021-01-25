#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf valid valid_?.log valid_script.temp
mkdir -p valid

extra_opts="--no-shuffle --seed 2222 --maxi-batch 1 --maxi-batch-sort none"
extra_opts="$extra_opts --dim-emb 128 --dim-rnn 256 --mini-batch 16"
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"


$MRT_MARIAN/marian $extra_opts \
    -m valid/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --valid-freq 20 --after-batches 150 --early-stopping 5 \
    --valid-metrics valid-script cross-entropy --valid-script-path ./valid_script.sh \
    --valid-sets $MRT_DATA/europarl.de-en/toy.bpe.{en,de} --valid-mini-batch 64 \
    --valid-log valid_1.log

test -e valid/model.npz
test -e valid/model.npz.yml
test -e valid_1.log

cp valid/model.npz.progress.yml valid/model.npz.progress.yml.bac
cat valid_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "valid-script" > valid.out

$MRT_MARIAN/marian $extra_opts \
    -m valid/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --valid-freq 20 --after-batches 300 --early-stopping 5 \
    --valid-metrics valid-script cross-entropy --valid-script-path ./valid_script.sh \
    --valid-sets $MRT_DATA/europarl.de-en/toy.bpe.{en,de} --valid-mini-batch 64 \
    --valid-log valid_2.log

test -e valid/model.npz
test -e valid_2.log

cat valid_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "valid-script" >> valid.out
$MRT_TOOLS/diff.sh valid.out valid.expected > valid.diff

# Exit with success code
exit 0
