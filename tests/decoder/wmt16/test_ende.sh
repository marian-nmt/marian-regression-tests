#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_RUN_MARIAN_DECODER -c $MRT_MODELS/wmt16_systems/marian.en-de.yml < text.in > text.out
diff text.out text.expected > text.diff

# Exit with success code
exit 0
