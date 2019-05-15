#!/bin/bash

#####################################################################
# SUMMARY: Test scoring sentences with a pretrained language model
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Run scorer
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/lmgec/config.yml -t $(pwd)/text.prep.en > lm_scores.out

# Compare scores
$MRT_TOOLS/diff-nums.py lm_scores.out lm_scores.expected -p 0.0003 -o lm_scores.diff

# Exit with success code
exit 0
