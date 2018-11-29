#!/bin/bash -x

#####################################################################
# SUMMARY: A template script for testing Marian decoder
# AUTHOR: <your-github-username>
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f decoder.{out,diff}

# Run marian decoder
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml < text.in > decoder.out

# Compare the output with the expected output
$MRT_TOOLS/diff.sh decoder.out text.expected > decoder.diff

# Exit with success code
exit 0
