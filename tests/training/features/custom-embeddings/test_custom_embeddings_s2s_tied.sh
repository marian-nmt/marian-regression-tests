#!/bin/bash -x

# Exit on error
set -e

#####################################################################
# SUMMARY: Load custom embeddings into a model with tied embeddings
# AUTHOR: snukky
#####################################################################

# Test code goes here
rm -rf custom_emb_tied custom_emb_tied.log
mkdir -p custom_emb_tied

# Train with custom embeddings only for one update with the smallest possible mini-batch, so that they should barely change
$MRT_MARIAN/marian --tied-embeddings-all --type s2s \
    -m custom_emb_tied/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.ende.yml vocab.ende.yml \
    --embedding-vectors word2vec.en word2vec.en --dim-emb 64 --dim-rnn 64 \
    --no-shuffle --mini-batch 1 --after-batches 1 --log custom_emb_tied.log

test -e custom_emb_tied/model.npz
test -e custom_emb_tied.log

# Check if loading of custom embeddings has been reported
grep -q "Loading embedding vectors from" custom_emb_tied.log

# Check if embeddings in the saved model are very similar to the original vectors
python3 $MRT_MARIAN/../scripts/embeddings/export_embeddings.py -m custom_emb_tied/model.npz -o custom_emb_tied.all

# The custom embeddings have been trained only for the first 100 words from each vocabulary
cat custom_emb_tied.all.all | head -n 101 > custom_emb_tied.all

$MRT_TOOLS/diff-nums.py -n 1 -p 0.0005 word2vec.en custom_emb_tied.all -o custom_emb_tied.all.diff

# Exit with success code
exit 0
