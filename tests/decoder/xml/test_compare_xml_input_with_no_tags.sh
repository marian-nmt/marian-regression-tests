#!/bin/bash -x

#####################################################################
# SUMMARY: Check if constrained decoding does not change an input without XML tags
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f notags*.{out,diff}

# Run marian decoder
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 10 -b 4 -n --n-best --xml-input < notags.in > notags.xml.out
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --mini-batch 10 -b 4 -n --n-best < notags.in > notags.noxml.out

# Compare the output with the expected output
$MRT_TOOLS/diff-nums.py notags.xml.out notags.noxml.out -o notags.diff

# Exit with success code
exit 0
