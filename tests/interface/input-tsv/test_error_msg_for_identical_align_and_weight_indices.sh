#!/bin/bash -x

#####################################################################
# SUMMARY: Indices for guided-alignment and data-weighting must differ
# TAGS: sentencepiece tsv train align
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf msg_align_weight_same_ids msg_align_weight_same_ids.log
mkdir -p msg_align_weight_same_ids

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 -m msg_align_weight_same_ids/model.npz \
    --tsv -t train2.de-w-en-aln.tsv -v msg_align_weight_same_ids/vocab.spm msg_align_weight_same_ids/vocab.spm --dim-vocabs 2000 2000 \
    --after-batches 1 --guided-alignment 3 --data-weighting 3 \
    > msg_align_weight_same_ids.log 2>&1 || true

test -e msg_align_weight_same_ids.log
grep -qi "tsv .*alignment .*weighting must.* be different" msg_align_weight_same_ids.log

# Exit with success code
exit 0
