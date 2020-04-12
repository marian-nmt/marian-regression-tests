#!/bin/bash

#####################################################################
# SUMMARY: Score a TSV input
# TAGS: multi-source sentencepiece tsv scorer
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f score.out

# Run Marian
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/rnn-spm/score.yml --tsv -t score.tsv -o score.out
# Compare outputs
$MRT_TOOLS/diff-nums.py score.out score.expected -p 0.0001 -o score.diff

# Exit with success code
exit 0
