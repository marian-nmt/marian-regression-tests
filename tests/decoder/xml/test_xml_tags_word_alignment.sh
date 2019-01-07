#!/bin/bash -x

#####################################################################
# SUMMARY: Test returning word alignments with constrained decoding
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f align.{out,diff}

# Run marian decoder
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.de-en.yml -b 3 -n --xml-input --alignment < tags.in > align.out

# Compare the output with the expected output
$MRT_TOOLS/diff.sh align.out align.expected > align.diff

# Exit with success code
exit 0
