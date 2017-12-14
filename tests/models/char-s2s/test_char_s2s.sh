#!/bin/bash

# Exit on error
set -e

# Skip if no CUDNN found
if [ ! $MRT_MARIAN_USE_CUDNN ]; then
    exit 100
fi

# Test code goes here
$MRT_RUN_MARIAN_DECODER -c $MRT_MODELS/char-s2s/translate.yml < text.in > text.out
diff text.out text.expected > text.diff

# Exit with success code
exit 0
