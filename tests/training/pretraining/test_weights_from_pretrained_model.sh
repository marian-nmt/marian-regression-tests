#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf model lm.log orig.log model.log key-*.txt
mkdir -p model

# Train LM
$MRT_MARIAN/marian \
    --seed 1111 --type lm -m model/lm.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.de --no-shuffle \
    -v model/vocab.de.yml \
    --log lm.log --after-batches 10

test -e lm.log
test -e model/lm.npz

# Train model without pretrained weights
$MRT_MARIAN/marian \
    --type s2s -m model/orig.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.en $MRT_DATA/europarl.de-en/corpus.bpe.de --no-shuffle \
    -v model/vocab.en.yml model/vocab.de.yml \
    --seed 2222 -l 0.0000000001 \
    --log orig.log --after-batches 1

test -e orig.log
test -e model/orig.npz

# Train model with weights initialized from LM
$MRT_MARIAN/marian \
    --type s2s -m model/model.npz --pretrained-model model/lm.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.en $MRT_DATA/europarl.de-en/corpus.bpe.de --no-shuffle \
    -v model/vocab.en.yml model/vocab.de.yml \
    --seed 2222 -l 0.0000000001 \
    --log model.log --after-batches 1

test -e model.log
test -e model/model.npz

# Test if selected weights are initialized randomly
for key in encoder_Wemb encoder_bi_U encoder_bi_r_Wx; do
    python3 $MRT_MARIAN/../scripts/contrib/model_info.py -m model/orig.npz -k $key > key-orig-$key.txt
    python3 $MRT_MARIAN/../scripts/contrib/model_info.py -m model/model.npz -k $key > key-model-$key.txt
    $MRT_TOOLS/diff-nums.py --numpy -p 0.000001 key-orig-$key.txt key-model-$key.txt -o key-diff-$key.txt
done

# Test if selected weights are identical with LM
for key in decoder_Wemb decoder_cell1_U decoder_cell2_bx decoder_ff_logit_l1_W0; do
    python3 $MRT_MARIAN/../scripts/contrib/model_info.py -m model/lm.npz -k $key > key-lm-$key.txt
    python3 $MRT_MARIAN/../scripts/contrib/model_info.py -m model/model.npz -k $key > key-model-$key.txt
    $MRT_TOOLS/diff-nums.py --numpy -p 0.000001 key-lm-$key.txt key-model-$key.txt -o key-diff-$key.txt
done

# Exit with success code
exit 0
