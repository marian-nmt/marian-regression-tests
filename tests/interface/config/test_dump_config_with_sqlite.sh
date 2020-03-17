#!/bin/bash

# Exit on error
set -e

rm -rf relpaths_sqlite.yml

# Run with no config file
$MRT_MARIAN/marian -c subdir/relpaths_sqlite.yml --mini-batch 8 --dump-config minimal > relpaths_sqlite.yml

test -e relpaths_sqlite.yml

grep -q "sqlite: temporary" relpaths_sqlite.yml

# Exit with success code
exit 0
