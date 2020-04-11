#!/bin/bash

#####################################################################
# SUMMARY: Assume the TSV input comes from STDIN if no data set is given
# TAGS: lm sentencepiece tsv scorer
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f assume_stdin.out

# Run Marian
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/lmgec/config.yml --tsv < score_lm.tsv > assume_stdin.out
# Compare outputs
$MRT_TOOLS/diff-nums.py assume_stdin.out score_lm.expected -p 0.0001 -o assume_stdin.diff

# Exit with success code
exit 0
