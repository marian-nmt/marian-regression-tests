#!/bin/bash

# Exit on error
set -e

rm -f nbest.out

# Run Marian
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/transformer/decode.yml -b 6 --mini-batch 32 --n-best < text.in > nbest.out

$MRT_TOOLS/diff-nums.py -p 0.0003 nbest.out text.b6.nbest.expected -o nbest.diff

# Exit with success code
exit 0
