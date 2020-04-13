#!/bin/bash -x

#####################################################################
# SUMMARY: Check if a dummy 'decoder_c_tt' matrix is created for the 'amun' model type
# AUTHOR: snukky
# TAGS: amun
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf decoder_c_tt
mkdir -p decoder_c_tt

opts="--no-shuffle --seed 1111 --mini-batch 32 --maxi-batch 1 --maxi-batch-sort none --optimizer sgd --dim-emb 64 --dim-rnn 128"

$MRT_MARIAN/marian \
    -m decoder_c_tt/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    $opts --after-batches 1

test -e decoder_c_tt/model.npz

python3 $MRT_MARIAN/../scripts/contrib/model_info.py -m decoder_c_tt/model.npz > decoder_c_tt.out
grep -q "decoder_c_tt" decoder_c_tt.out

# Exit with success code
exit 0
