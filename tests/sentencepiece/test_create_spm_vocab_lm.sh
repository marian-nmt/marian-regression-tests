#!/bin/bash -x

#####################################################################
# SUMMARY: Create SentencePiece vocabulary for a language model
# AUTHOR: snukky
# TAGS: sentencepiece
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf vocab.lm vocab.lm.*{log,out,diff}
mkdir -p vocab.lm

# Run marian command
$MRT_MARIAN/marian --type lm \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none \
    -m vocab.lm/model.npz -t $MRT_DATA/europarl.de-en/corpus.small.en.gz \
    --dim-vocabs 4000 -v vocab.lm/vocab.en.spm \
    --after-batches 1 \
    --log vocab.lm.log

# Check if files exist
test -e vocab.lm/vocab.en.spm
test -e vocab.lm.log

# Check logging messages
grep -q "Training SentencePiece vocabulary .*vocab.en.spm" vocab.lm.log
grep -q "Setting vocabulary size .* to 4,\?000" vocab.lm.log
grep -q "Loading SentencePiece vocabulary .*vocab.en.spm" vocab.lm.log

# Extract a textual vocabulary and compare with the expected output
LC_ALL=C $MRT_MARIAN/spm_export_vocab --model vocab.lm/vocab.en.spm | sort > vocab.lm.out

$MRT_TOOLS/diff-nums.py vocab.lm.out vocabs.en.expected -o vocab.lm.diff

# Exit with success code
exit 0
