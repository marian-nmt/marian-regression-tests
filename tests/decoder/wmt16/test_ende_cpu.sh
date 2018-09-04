#!/bin/bash

# Exit on error
set -e


# Skip if no MKL found
if [ ! $MRT_MARIAN_USE_MKL ]; then
    exit 100
fi

# Test code goes here
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --cpu-threads 4 < text.in > text_cpu.out
diff text_cpu.out text.expected > text_cpu.diff

# Exit with success code
exit 0
