#!/bin/bash -x

#####################################################################
# SUMMARY: Test constrained decoding with high violation penalty
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f vp.{out,diff}

# Run marian decoder
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.de-en.yml --mini-batch 10 -b 3 --xml-input --n-best --xml-violation-penalty 99 < text.in > vp.out

# Compare the output with the expected output
$MRT_TOOLS/diff-nums.py vp.out vp.expected -o vp.diff

# Exit with success code
exit 0
