#!/bin/bash

#####################################################################
# SUMMARY: Score a TSV input from STDIN with a language model
# TAGS: lm sentencepiece tsv scorer
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f score_lm_stdin.out

# Run Marian
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/lmgec/config.yml --tsv -t stdin < score_lm.tsv > score_lm_stdin.out
# Compare outputs
$MRT_TOOLS/diff-nums.py score_lm_stdin.out score_lm.expected -p 0.0001 -o score_lm_stdin.diff

# Exit with success code
exit 0
