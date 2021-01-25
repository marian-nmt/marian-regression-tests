#!/bin/bash -x

#####################################################################
# SUMMARY: Create a SentencePiece vocabulary using --sentencepiece-max-lines
# AUTHOR: snukky
# TAGS: sentencepiece
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf vocab.maxlines vocab.maxlines.*{log,out,diff}
mkdir -p vocab.maxlines

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --after-batches 1 \
    -m vocab.maxlines/model.npz -t $MRT_DATA/europarl.de-en/corpus.small.{en,de}.gz \
    --dim-vocabs 4000 -v vocab.maxlines/vocab.ende.spm vocab.maxlines/vocab.ende.spm --sentencepiece-max-lines 2345 \
    --sentencepiece-options "--num_threads=1" \
    --log vocab.maxlines.log

# Check if files exist
test -e vocab.maxlines/model.npz
test -e vocab.maxlines/vocab.ende.spm
test -e vocab.maxlines.log

# Check logging messages
grep -q "Training SentencePiece vocabulary .*vocab.ende.spm" vocab.maxlines.log
grep -q "Setting vocabulary size .* to 4,\?000" vocab.maxlines.log
grep -q "Sampling at most 2345 lines from" vocab.maxlines.log
grep -q "Loading SentencePiece vocabulary .*vocab.ende.spm" vocab.maxlines.log

# Extract a textual vocabulary and compare with the expected output
LC_ALL=C $MRT_MARIAN/spm_export_vocab --model vocab.maxlines/vocab.ende.spm | sort > vocab.maxlines.out
$MRT_TOOLS/diff-nums.py vocab.maxlines.out vocab.maxlines.expected -o vocab.maxlines.diff

# Exit with success code
exit 0
