#!/bin/bash -x

#####################################################################
# SUMMARY: Train a multi-source Transformer model
# AUTHOR: snukky
# TAGS: multisource transformer
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf multi-transformer multi-transformer.log
mkdir -p multi-transformer

$MRT_MARIAN/marian \
    --seed 1111 --no-shuffle \
    --type multi-transformer --dim-emb 128 --dim-rnn 256 --cost-type ce-mean \
    -m multi-transformer/model.npz -t train.bpe.{en,xx,de} -v vocab.en.yml vocab.xx.yml vocab.de.yml \
    --disp-freq 20 --after-batches 100 \
    --log multi-transformer.log

test -e multi-transformer/model.npz
test -e multi-transformer/model.npz.yml
test -e multi-transformer.log

cat multi-transformer.log | grep 'Ep\. 1 :' | $MRT_TOOLS/extract-costs.sh > multi-transformer.out
$MRT_TOOLS/diff-nums.py multi-transformer.out multi-transformer.expected -p 0.2 -o multi-transformer.diff

# Exit with success code
exit 0
