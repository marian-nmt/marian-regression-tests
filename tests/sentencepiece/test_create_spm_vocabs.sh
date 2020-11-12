#!/bin/bash -x

#####################################################################
# SUMMARY: Create SentencePiece vocabularies
# AUTHOR: snukky
# TAGS: sentencepiece
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf vocabs vocabs.*{log,out,diff}
mkdir -p vocabs

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none \
    -m vocabs/model.npz -t $MRT_DATA/europarl.de-en/corpus.small.{en,de}.gz \
    --dim-vocabs 4000 4000 -v vocabs/vocab.en.spm vocabs/vocab.de.spm --sentencepiece-options "--num_threads=1" \
    --after-batches 1 \
    --log vocabs.log

# Check if files exist
test -e vocabs/model.npz
test -e vocabs/vocab.en.spm
test -e vocabs/vocab.de.spm
test -e vocabs.log

# Check logging messages
grep -q "Training SentencePiece vocabulary .*vocab.en.spm" vocabs.log
grep -q "Training SentencePiece vocabulary .*vocab.de.spm" vocabs.log
grep -q "Setting vocabulary size .* to 4,\?000" vocabs.log
grep -q "Loading SentencePiece vocabulary .*vocab.en.spm" vocabs.log
grep -q "Loading SentencePiece vocabulary .*vocab.de.spm" vocabs.log

# Extract a textual vocabulary and compare with the expected output
LC_ALL=C $MRT_MARIAN/spm_export_vocab --model vocabs/vocab.en.spm | sort > vocabs.en.out
LC_ALL=C $MRT_MARIAN/spm_export_vocab --model vocabs/vocab.de.spm | sort > vocabs.de.out

$MRT_TOOLS/diff-nums.py vocabs.en.out vocabs.en.expected -o vocabs.en.diff
$MRT_TOOLS/diff-nums.py vocabs.de.out vocabs.de.expected -o vocabs.de.diff

# Exit with success code
exit 0
