#!/bin/bash -x

#####################################################################
# SUMMARY: Create SentencePiece vocabularies
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf vocabs vocabs.*{log,out,diff}
mkdir -p vocabs

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none \
    -m vocabs/model.npz -t $MRT_DATA/europarl.de-en/corpus.{en,de} \
    --dim-vocabs 4000 4000 -v vocabs/vocab.en.spm vocabs/vocab.de.spm \
    --after-batches 1 \
    --log vocabs.log

# Check if files exist
test -e vocabs/model.npz
test -e vocabs/vocab.en.spm
test -e vocabs/vocab.de.spm
test -e vocabs.log

# Check logging messages
grep -q "Creating SentencePiece vocabulary.* vocabs.en.spm" vocabs.log
grep -q "Creating SentencePiece vocabulary.* vocabs.de.spm" vocabs.log

# Extract a textual vocabulary and compare with the expected output
$MRT_MRT/spm_export_vocab --model vocabs/vocab.en.spm > vocabs.en.out
$MRT_TOOLS/diff-nums.py vocabs.en.out vocabs.en.expected -o vocabs.en.diff

$MRT_MRT/spm_export_vocab --model vocabs/vocab.de.spm > vocabs.de.out
$MRT_TOOLS/diff-nums.py vocabs.de.out vocabs.de.expected -o vocabs.de.diff

# Exit with success code
exit 0
