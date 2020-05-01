#!/bin/bash

#####################################################################
# SUMMARY: Translate a single-source input with --tsv option enabled
# TAGS: sentencepiece tsv
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f decode.out

# Run Marian
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/rnn-spm/decode.yml -b 6 --tsv -i decode.txt -o decode.out
# Compare outputs
$MRT_TOOLS/diff.sh decode.out decode.expected > decode.diff

# Exit with success code
exit 0
