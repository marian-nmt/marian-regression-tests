#!/bin/bash

#####################################################################
# SUMMARY: Score a TSV input with a language model
# TAGS: lm sentencepiece tsv scorer
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f score_lm.out

# Run Marian
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/lmgec/config.yml --tsv -t score_lm.tsv -o score_lm.out
# Compare outputs
$MRT_TOOLS/diff-nums.py score_lm.out score_lm.expected -p 0.0001 -o score_lm.diff

# Exit with success code
exit 0
