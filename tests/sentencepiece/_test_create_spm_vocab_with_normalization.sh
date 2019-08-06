#!/bin/bash -x

#####################################################################
# SUMMARY: Create SentencePiece vocabulary with normalization
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf norm norm*{log,out,diff}
mkdir -p norm

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none \
    -m norm/model.npz -t $MRT_DATA/europarl.de-en/corpus.{en,de} \
    --dim-vocabs 4000 4000 -v norm/vocab.spm --sentencepiece-options '--normalization_rule_tsv=norm.tsv' \
    --after-batches 1 \
    --log norm.log

# Check if files exist
test -e norm/vocab.spm
test -e norm.log

# Check logging messages
grep -q "Creating SentencePiece vocabulary.* vocabs.spm" norm.log
grep -q "Using normalization file.* norm.tsv" norm.log

# Encode text with the created vocabulary and compare it with the expected output
$MRT_MARIAN/spm_encode --model norm/norm.spm < text.in > norm.out
$MRT_TOOLS/diff.sh text.in norm.out > norm.diff

# Exit with success code
exit 0
