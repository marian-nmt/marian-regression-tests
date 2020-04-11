#!/bin/bash

#####################################################################
# SUMMARY: Assume the input is in TSV format if the only data set is "stdin"
# TAGS: lm sentencepiece tsv scorer
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f assume_tsv.out

# Run Marian
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/lmgec/config.yml -t stdin < score_lm.tsv > assume_tsv.out
# Compare outputs
$MRT_TOOLS/diff-nums.py assume_tsv.out score_lm.expected -p 0.0001 -o assume_tsv.diff

# Exit with success code
exit 0
