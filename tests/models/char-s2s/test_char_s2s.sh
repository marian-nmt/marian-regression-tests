#!/bin/bash

# Exit on error
set -e

# Skip if no CUDNN found
if [ ! $MRT_MARIAN_USE_CUDNN ]; then
    exit 100
fi

# Test code goes here
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/char-s2s/translate.yml < text.in > text.out
diff $(pwd)/text.out $(pwd)/text.expected | tee $(pwd)/text.diff | head

# Exit with success code
exit 0
