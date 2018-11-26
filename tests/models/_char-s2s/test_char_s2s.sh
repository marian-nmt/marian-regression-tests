#!/bin/bash

# Exit on error
set -e

# Skip if no CUDNN found
if [ ! $MRT_MARIAN_USE_CUDNN ]; then
    exit 100
fi

# Test code goes here
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/char-s2s/translate.yml < text.in > text.out
$MRT_TOOLS/diff.sh text.out text.expected > text.diff

# Exit with success code
exit 0
