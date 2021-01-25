#!/bin/bash -x

#####################################################################
# SUMMARY: Creating a vocabulary from a TSV file with alignment in not supported
# TAGS: sentencepiece tsv train align
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf msg_train_vocab_align msg_train_vocab_align.log
mkdir -p msg_train_vocab_align

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 -m msg_train_vocab_align/model.npz \
    --tsv -t train2.de-en-aln.tsv -v msg_train_vocab_align/vocab.spm msg_train_vocab_align/vocab.spm --dim-vocabs 2000 2000 \
    --after-batches 1 --guided-alignment 2 \
    > msg_train_vocab_align.log 2>&1 || true

test -e msg_train_vocab_align.log
grep -qi "creating vocab.* tsv data with alignment.* not supported" msg_train_vocab_align.log

# Exit with success code
exit 0
