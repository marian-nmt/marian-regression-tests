#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf valid_stalled valid_stalled_?.*log valid_script_?.temp
mkdir -p valid_stalled

head -n 8 $MRT_DATA/europarl.de-en/toy.bpe.en > valid.mini.bpe.en
head -n 8 $MRT_DATA/europarl.de-en/toy.bpe.de > valid.mini.bpe.de


#$MRT_MARIAN/build/marian \
    #--no-shuffle --seed 2222 --maxi-batch 1 --maxi-batch-sort none --quiet-translation \
    #--dim-emb 64 --dim-rnn 128 --mini-batch 16 --optimizer sgd \
    #-m valid_stalled_full/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    #--disp-freq 10 --valid-freq 20 --after-batches 200 --early-stopping 5 \
    #--valid-metrics cross-entropy valid-script translation --valid-script-path ./valid_script_ab.sh \
    #--valid-sets valid.mini.bpe.{de,en} \
    #--overwrite --keep-best \
    #--log valid_stalled_full.log

#cat valid_stalled_full.log | $MRT_TOOLS/strip-timestamps.sh \
    #| grep -P "\[valid\]|Saving model" | grep -v "cross-entropy" \
    #> valid_stalled.expected


$MRT_MARIAN/build/marian \
    --no-shuffle --seed 2222 --maxi-batch 1 --maxi-batch-sort none --quiet-translation \
    --dim-emb 64 --dim-rnn 128 --mini-batch 16 --optimizer sgd \
    -m valid_stalled/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --valid-freq 20 --after-batches 100 --early-stopping 5 \
    --valid-metrics cross-entropy valid-script translation --valid-script-path ./valid_script_ab.sh \
    --valid-sets valid.mini.bpe.{de,en} \
    --overwrite --keep-best \
    --log valid_stalled_1.log

test -e valid_stalled/model.npz
test -e valid_stalled/model.npz.yml
test -e valid_stalled_1.log

cp valid_stalled/model.npz.progress.yml valid_stalled/model.npz.progress.yml.bac
cat valid_stalled_1.log | $MRT_TOOLS/strip-timestamps.sh \
    | grep -P "\[valid\]|Saving model" | grep -v "cross-entropy" \
    | head -n -1 > valid_stalled.out


$MRT_MARIAN/build/marian \
    --no-shuffle --seed 2222 --maxi-batch 1 --maxi-batch-sort none --quiet-translation \
    --dim-emb 64 --dim-rnn 128 --mini-batch 16 --optimizer sgd \
    -m valid_stalled/model.npz -t $MRT_DATA/europarl.de-en/toy.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --valid-freq 20 --after-batches 200 --early-stopping 5 \
    --valid-metrics cross-entropy valid-script translation --valid-script-path ./valid_script_ab.sh \
    --valid-sets valid.mini.bpe.{de,en} \
    --overwrite --keep-best \
    --log valid_stalled_2.log

test -e valid_stalled/model.npz
test -e valid_stalled_2.log

cat valid_stalled_2.log | $MRT_TOOLS/strip-timestamps.sh \
    | grep -P "\[valid\]|Saving model" | grep -v "cross-entropy" >> valid_stalled.out
diff valid_stalled.out valid_stalled.expected > valid_stalled.diff

# Exit with success code
exit 0
