#!/bin/bash

# Exit on error
set -e

rm -f nomodel_decoder.log
echo "this is a test ." > file.in

# Test code goes here
$MRT_MARIAN/marian-decoder --type amun --dim-emb 500 --dim-vocabs 85000 85000 \
    -i file.in > nomodel_decoder.log 2>&1 || true

test -e nomodel_decoder.log
grep -q "need to provide .* model file" nomodel_decoder.log

# Exit with success code
exit 0
