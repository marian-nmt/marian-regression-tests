#!/bin/bash

#####################################################################
# SUMMARY: Generate an n-best list with a dual-source APE model
# TAGS: multi-source transformer sentencepiece n-best
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f nbest.out

# Run Marian
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/ape/config.yml --n-best -b 4 -i text.src text.mt -o nbest.out
# Compare outputs
$MRT_TOOLS/diff-nums.py -p 0.0003 nbest.out text.b4.nbest.expected -o nbest.diff

# Exit with success code
exit 0
