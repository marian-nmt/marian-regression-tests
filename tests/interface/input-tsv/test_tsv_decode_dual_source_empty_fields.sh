#!/bin/bash

#####################################################################
# SUMMARY: Translate a TSV input with empty lines or fields
# TAGS: multi-source transformer sentencepiece tsv
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f decode_ape_empty_fields.out

# Run Marian
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/ape/config.yml -b 6 -i decode_ape_empty_fields.tsv --tsv -o decode_ape_empty_fields.out
# Compare outputs
$MRT_TOOLS/diff.sh decode_ape_empty_fields.out decode_ape_empty_fields.expected > decode_ape_empty_fields.diff

# Exit with success code
exit 0
