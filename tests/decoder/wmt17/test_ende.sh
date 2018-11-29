#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt17_systems/marian.en-de.yml < text.in | tail -n 99 > text.out
$MRT_TOOLS/diff.sh text.out text.expected > text.diff

# Exit with success code
exit 0
