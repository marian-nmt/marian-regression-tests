#!/bin/bash

# Exit on error
set -e

rm -rf dump_relpaths.yml

# Run with no config file
$MRT_MARIAN/marian-decoder -c relpaths.yml --mini-batch 8 --dump-config > dump_relpaths.yml

test -e dump_relpaths.yml

grep -q "type: amun" dump_relpaths.yml
grep -q "mini-batch: 8" dump_relpaths.yml
grep -q "dim-emb: 500" dump_relpaths.yml
grep -q "  - .*wmt16_systems/en-de" dump_relpaths.yml

# Exit with success code
exit 0
