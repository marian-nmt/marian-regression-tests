#!/bin/bash

# Exit on error
set -e

# Check if amun is compiled
test -e $MRT_MARIAN/build/amun || exit $EXIT_CODE_SKIP

# Test code goes here
B=5
$MRT_MARIAN/build/amun -c $MRT_MODELS/wmt16_systems/amun.en-de.yml --return-alignment -b $B < text.in > amun.align.out
$MRT_MARIAN/build/amun -c $MRT_MODELS/wmt16_systems/amun.en-de.yml --return-soft-alignment -b $B < text.in > amun.soft.out
$MRT_MARIAN/build/amun -c $MRT_MODELS/wmt16_systems/amun.en-de.yml --return-nematus-alignment -b $B < text.in > amun.nematus.out

# Exit with success code
exit 0
