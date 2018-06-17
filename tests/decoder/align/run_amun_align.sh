#!/bin/bash

# Exit on error
set -e

# Check if amun is compiled
test -e $MRT_MARIAN/build/amun || exit $EXIT_CODE_SKIP

# Test code goes here
$MRT_MARIAN/build/amun -c $MRT_MODELS/wmt16_systems/amun.en-de.yml --return-alignment -b 1 < text.in > amun.align.out
#cat amun.align.out | sed 's/ ||| /\t/' | cut -f1 > amun.out
#diff amun.align.out amun.align.expected > amun.align.diff

# Exit with success code
exit 0
