#!/bin/bash -x

# Exit on error
set -e

#####################################################################
# SUMMARY: Load custom embeddings into an RNN model
# AUTHOR: snukky
#####################################################################

# Test code goes here
rm -rf custom_emb custom_emb.log
mkdir -p custom_emb

# Train with custom embeddings only for one update with the smallest possible mini-batch, so that they should barely change
$MRT_MARIAN/marian \
    -m custom_emb/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --embedding-vectors word2vec.en word2vec.de --dim-emb 64 --dim-rnn 64 \
    --no-shuffle --mini-batch 1 --after-batches 1 --log custom_emb.log

test -e custom_emb/model.npz
test -e custom_emb.log

# Check if loading of custom embeddings has been reported
grep -q "Loading embedding vectors from" custom_emb.log

# Check if embeddings in the saved model are very similar to the original vectors
python3 $MRT_MARIAN/../scripts/embeddings/export_embeddings.py -m custom_emb/model.npz -o custom_emb.all

# The custom embeddings have been trained only for the first 100 words from each vocabulary
cat custom_emb.all.src | head -n 101 > custom_emb.src
cat custom_emb.all.trg | head -n 101 > custom_emb.trg

$MRT_TOOLS/diff-nums.py -n 1 -p 0.0005 word2vec.en custom_emb.src -o custom_emb.src.diff
$MRT_TOOLS/diff-nums.py -n 1 -p 0.0005 word2vec.de custom_emb.trg -o custom_emb.trg.diff

# Exit with success code
exit 0
