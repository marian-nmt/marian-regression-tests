#!/bin/bash -x

#####################################################################
# SUMMARY: Test constrained decoding with expected translations in XML tags
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f simpletags*.{out,diff}

# Run marian decoder
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 10 -b 4 -n --xml-input < simpletags.in > simpletags.xml.out
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 10 -b 4 -n < notags.in > simpletags.noxml.out

# Compare the output with the expected output
$MRT_TOOLS/diff-nums.py simpletags.xml.out simpletags.noxml.out -o simpletags.diff

# Exit with success code
exit 0
