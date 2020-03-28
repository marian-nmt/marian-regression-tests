#!/bin/bash

#####################################################################
# SUMMARY: Translate a TSV input from STDIN with a dual-source APE model
# TAGS: multi-source transformer sentencepiece tsv stdin
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f decode_ape_stdin.out

# Run Marian
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/ape/config.yml -b 6 --tsv < decode_ape.tsv > decode_ape_stdin.out
# Compare outputs
$MRT_TOOLS/diff.sh decode_ape_stdin.out decode_ape.expected > decode_ape_stdin.diff

# Exit with success code
exit 0
