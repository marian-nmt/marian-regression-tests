#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml < text.in 2> logs.raw
cat logs.raw | grep "] Best translation" | sed -r "s/.*Best translation [0-9]+ : (.*)/\1/" > logs.out
diff $(pwd)/logs.out $(pwd)/text.expected | tee $(pwd)/logs.diff | head

# Exit with success code
exit 0
