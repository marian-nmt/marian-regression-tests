#!/bin/bash

#####################################################################
# SUMMARY: Score a TSV input from STDIN
# TAGS: multi-source sentencepiece tsv score_stdinr stdin
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f score_stdin.out

# Run Marian
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/rnn-spm/score.yml --tsv -t stdin < score.tsv > score_stdin.out
# Compare outputs
$MRT_TOOLS/diff-nums.py score_stdin.out score.expected -p 0.0001 -o score_stdin.diff

# Exit with success code
exit 0
