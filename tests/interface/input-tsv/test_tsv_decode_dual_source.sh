#!/bin/bash

#####################################################################
# SUMMARY: Translate a TSV input with a dual-source APE model
# TAGS: multi-source transformer sentencepiece tsv
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f decode_ape.out

# Run Marian
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/ape/config.yml -b 6 -i decode_ape.tsv --tsv -o decode_ape.out
# Compare outputs
$MRT_TOOLS/diff.sh decode_ape.out decode_ape.expected > decode_ape.diff

# Exit with success code
exit 0
