#!/bin/bash -x

#####################################################################
# SUMMARY: Test constrained decoding with larger mini-batch
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f batch8.{out,diff}

# Run marian decoder
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.de-en.yml -b 4 -n --xml-input --n-best --mini-batch 8 < text.in > batch8.out

# Compare the output with the expected output
$MRT_TOOLS/diff-nums.py batch8.out nbest.expected -o batch8.diff

# Exit with success code
exit 0
