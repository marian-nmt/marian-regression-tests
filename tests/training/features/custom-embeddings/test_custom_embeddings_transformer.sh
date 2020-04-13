#!/bin/bash -x

# Exit on error
set -e

#####################################################################
# SUMMARY: Load custom embeddings into a transformer model
# AUTHOR: snukky
#####################################################################


# Test code goes here
rm -rf custom_emb_transformer custom_emb_transformer.log
mkdir -p custom_emb_transformer

# Train with custom embeddings only for one update with the smallest possible mini-batch, so that they should barely change
$MRT_MARIAN/marian --type transformer --enc-depth 2 --dec-depth 2  \
    -m custom_emb_transformer/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --embedding-vectors word2vec.en word2vec.de --dim-emb 64 --transformer-dim-ffn 256 \
    --no-shuffle --mini-batch 1 --after-batches 1 --log custom_emb_transformer.log

test -e custom_emb_transformer/model.npz
test -e custom_emb_transformer.log

# Check if loading of custom embeddings has been reported
grep -q "Loading embedding vectors from" custom_emb_transformer.log

# Check if embeddings in the saved model are very similar to the original vectors
python3 $MRT_MARIAN/../scripts/embeddings/export_embeddings.py -m custom_emb_transformer/model.npz -o custom_emb_transformer.all

# The custom embeddings have been trained only for the first 100 words from each vocabulary
cat custom_emb_transformer.all.src | head -n 101 > custom_emb_transformer.src
cat custom_emb_transformer.all.trg | head -n 101 > custom_emb_transformer.trg

$MRT_TOOLS/diff-nums.py -n 1 -p 0.0005 word2vec.en custom_emb_transformer.src -o custom_emb_transformer.src.diff
$MRT_TOOLS/diff-nums.py -n 1 -p 0.0005 word2vec.de custom_emb_transformer.trg -o custom_emb_transformer.trg.diff

# Exit with success code
exit 0
