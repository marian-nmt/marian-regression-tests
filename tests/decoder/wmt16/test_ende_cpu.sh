#!/bin/bash

#####################################################################
# SUMMARY: Translate on CPU using an Amun model
# TAGS: cpu rnn
#####################################################################

# Exit on error
set -e

# Skip if no MKL found
if [ ! $MRT_MARIAN_USE_MKL ]; then
    exit 100
fi

# Test code goes here
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml --cpu-threads 4 < text.in > text_cpu.out
$MRT_TOOLS/diff.sh text_cpu.out text.expected > text_cpu.diff

# Exit with success code
exit 0
