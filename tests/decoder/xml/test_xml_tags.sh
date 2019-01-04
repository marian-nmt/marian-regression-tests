#!/bin/bash -x

#####################################################################
# SUMMARY: Test different variants of XML tags
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f tags.{out,diff}

# Run marian decoder
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.de-en.yml -b 2 -n --xml-input < tags.in > tags.out

# Compare the output with the expected output
$MRT_TOOLS/diff.sh tags.out tags.expected > tags.diff

# Exit with success code
exit 0
