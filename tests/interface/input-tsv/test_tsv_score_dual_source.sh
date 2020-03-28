#!/bin/bash

#####################################################################
# SUMMARY: Score a TSV input with a dual-source APE model
# TAGS: multi-source sentencepiece tsv scorer
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f score_ape.out

# Run Marian
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/ape/score.yml --tsv -t score_ape.tsv -o score_ape.out
# Compare outputs
$MRT_TOOLS/diff-nums.py score_ape.out score_ape.expected -p 0.0001 -o score_ape.diff

# Exit with success code
exit 0
