#!/bin/bash -x

#####################################################################
# SUMMARY: Create a joint SentencePiece vocabulary
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf vocab.joint vocab.joint.*{log,out,diff}
mkdir -p vocab.joint

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 32 --dim-rnn 64 --maxi-batch 1 --maxi-batch-sort none --after-batches 1 \
    -m vocab.joint/model.npz -t $MRT_DATA/europarl.de-en/corpus.{en,de} \
    --dim-vocabs 8000 -v vocab.joint/vocab.ende.spm vocab.joint/vocab.ende.spm \
    --log vocab.joint.log

# Check if files exist
test -e vocab.joint/model.npz
test -e vocab.joint/vocab.ende.spm
test -e vocab.joint.log

# Check logging messages
grep -q "Creating SentencePiece vocabulary.* vocab.ende.spm" vocabs.joint.log
grep -q "Sampling from.* corpus.en.* corpus.de" vocabs.joint.log

# Extract a textual vocabulary and compare with the expected output
$MRT_MRT/spm_export_vocab --model vocab.joint/vocab.ende.spm > vocab.joint.out
$MRT_TOOLS/diff-nums.py vocab.joint.out vocab.joint.expected -o vocab.joint.diff

# Exit with success code
exit 0
