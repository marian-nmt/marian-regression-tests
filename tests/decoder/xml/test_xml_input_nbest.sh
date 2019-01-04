#!/bin/bash -x

#####################################################################
# SUMMARY: Test constrained decoding with n-best output
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f nbest.{out,diff}

# Run marian decoder
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.de-en.yml -b 4 -n --xml-input --n-best < text.in > nbest.out

# Compare the output with the expected output
$MRT_TOOLS/diff-nums.py nbest.out nbest.expected -o nbest.diff

# Exit with success code
exit 0
