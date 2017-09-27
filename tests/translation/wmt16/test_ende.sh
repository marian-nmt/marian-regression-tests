#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/build/s2s -c $MRT_MODELS/wmt16.en-de/marian.yml < text.in > text.out
diff -q text.out text.expected

# Exit with success code
exit 0
