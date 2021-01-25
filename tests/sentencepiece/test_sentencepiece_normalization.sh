#!/bin/bash -x

#####################################################################
# SUMMARY: Create a SentencePiece vocabulary with normalization rules
# AUTHOR: snukky
# TAGS: sentencepiece
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf vocab.norm vocab.norm.*{log,out,diff}
mkdir -p vocab.norm

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 2222 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --after-batches 1 \
    -m vocab.norm/model.npz -t $MRT_DATA/europarl.de-en/corpus.small.{en,de}.gz \
    --dim-vocabs 4000 -v vocab.norm/vocab.ende.spm vocab.norm/vocab.ende.spm --sentencepiece-options '--normalization_rule_tsv=norm.tsv --num_threads=1' --sentencepiece-max-lines 10000 \
    --log vocab.norm.log

# Check if files exist
test -e vocab.norm/model.npz
test -e vocab.norm/vocab.ende.spm
test -e vocab.norm.log

# Check logging messages
grep -q "Training SentencePiece vocabulary .*vocab.ende.spm" vocab.norm.log

# Extract a textual vocabulary and compare with the expected output
LC_ALL=C $MRT_MARIAN/spm_export_vocab --model vocab.norm/vocab.ende.spm | sort > vocab.norm.out
$MRT_TOOLS/diff-nums.py vocab.norm.out vocab.norm.expected -o vocab.norm.diff

# Normalization is uppercasing, so check if there is no lowercased ASCII characters
grep -qvP '[a-z]' vocab.norm.out

# Exit with success code
exit 0
