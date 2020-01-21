#!/bin/bash

#####################################################################
# SUMMARY: Check word alignment generated from a Transformer on CPU
# TAGS: cpu align transformer
#####################################################################

# Exit on error
set -e

# Skip if no MKL found
if [ ! $MRT_MARIAN_USE_MKL ]; then
    exit 100
fi

rm -f hardalign.cpu.out

# Run Marian
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/transformer/decode.yml -b 3 --mini-batch 32 --alignment --cpu-threads 2 < text.in > hardalign.cpu.out
$MRT_TOOLS/diff.sh hardalign.cpu.out text.b3.hardalign.expected > hardalign.cpu.diff

# Exit with success code
exit 0
