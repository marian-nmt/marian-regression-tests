#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt17_systems/marian.en-de.yml < text.in | tail -n 99 > text.out
diff text.out text.expected > text.diff

# Exit with success code
exit 0
