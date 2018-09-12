#!/bin/bash

# Exit on error
set -e

rm -f softalign.out

# Run Marian
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/transformer/decode.yml -b 6 --mini-batch 32 --alignment soft < text.in > softalign.out

$MRT_TOOLS/diff-floats.py -p 0.0001 softalign.out text.b6.softalign.expected > softalign.diff

# Exit with success code
exit 0
