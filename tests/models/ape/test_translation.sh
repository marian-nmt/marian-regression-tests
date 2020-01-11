#!/bin/bash

#####################################################################
# SUMMARY: Translate with a dual-source APE model
# TAGS: multi-source transformer sentencepiece
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f ape.out

# Run Marian
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/ape/config.yml -b 6 -i text.src text.mt -o ape.out
# Compare outputs
$MRT_TOOLS/diff.sh ape.out text.b6.expected > ape.diff

# Exit with success code
exit 0
