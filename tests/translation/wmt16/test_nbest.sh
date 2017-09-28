#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/build/s2s -c $MRT_MODELS/wmt16.en-de/marian.yml -b 5 --n-best < text.in > nbest.out
diff nbest.out nbest.expected | tee nbest.diff

# Exit with success code
exit 0
