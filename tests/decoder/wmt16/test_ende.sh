#!/bin/bash

# Exit on error
set -eo pipefail

# Test code goes here
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml < text.in > text.out
diff $(pwd)/text.out $(pwd)/text.expected | tee $(pwd)/text.diff | head

# Exit with success code
exit 0
