#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf valid_newbest valid_newbest_*.log valid_script_?.temp
mkdir -p valid_newbest

head -n 8 $MRT_DATA/europarl.de-en/toy.bpe.en > valid.mini.bpe.en
head -n 8 $MRT_DATA/europarl.de-en/toy.bpe.de > valid.mini.bpe.de


# Uncomment to re-generate the expected output

#$MRT_MARIAN/marian \
    #--type s2s --no-shuffle --seed 2222 --maxi-batch 1 --maxi-batch-sort none --quiet-translation \
    #--dim-emb 64 --dim-rnn 128 --mini-batch 16 --optimizer sgd --cost-type ce-mean \
    #-m valid_newbest/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    #--disp-freq 5 --valid-freq 10 --after-batches 100 \
    #--valid-metrics cross-entropy translation --valid-script-path ./count_bytes.sh \
    #--valid-sets valid.mini.bpe.{de,en} \
    #--overwrite --keep-best \
    #--log valid_newbest_full.log

#cat valid_newbest_full.log | $MRT_TOOLS/strip-timestamps.sh | grep -P "\[valid\]" > valid_newbest.expected
#exit 1


$MRT_MARIAN/marian \
    --type s2s --no-shuffle --seed 2222 --maxi-batch 1 --maxi-batch-sort none --quiet-translation \
    --dim-emb 64 --dim-rnn 128 --mini-batch 16 --optimizer sgd --cost-type ce-mean \
    -m valid_newbest/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 5 --valid-freq 10 --after-batches 50 \
    --valid-metrics cross-entropy translation --valid-script-path ./count_bytes.sh \
    --valid-sets valid.mini.bpe.{de,en} \
    --keep-best \
    --log valid_newbest_1.log

test -e valid_newbest/model.npz
test -e valid_newbest/model.npz.yml
test -e valid_newbest_1.log

cp valid_newbest/model.npz.progress.yml valid_newbest/model.npz.progress.yml.bac
cat valid_newbest_1.log | $MRT_TOOLS/strip-timestamps.sh | grep -P "\[valid\]" > valid_newbest.out


$MRT_MARIAN/marian \
    -m valid_newbest/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 100 --log valid_newbest_2.log

test -e valid_newbest/model.npz
test -e valid_newbest_2.log

cat valid_newbest_2.log | $MRT_TOOLS/strip-timestamps.sh | grep -P "\[valid\]" >> valid_newbest.out
$MRT_TOOLS/diff.sh valid_newbest.out valid_newbest.expected > valid_newbest.diff

# Exit with success code
exit 0
