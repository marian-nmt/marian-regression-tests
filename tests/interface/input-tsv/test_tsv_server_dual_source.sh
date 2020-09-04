#!/bin/bash

#####################################################################
# SUMMARY: Translate a single-source input with --tsv using marian-server
# TAGS: multi-source transformer sentencepiece tsv server
#####################################################################

# Exit on error
set -e

# Check if marian-server is compiled
test -f $MRT_MARIAN/marian-server || exit $EXIT_CODE_SKIP

clean_up() {
    kill $SERVER_PID
}
trap clean_up EXIT

# Remove old artifacts
rm -f server_ape.out

# Run Marian
$MRT_MARIAN/marian-server -c $MRT_MODELS/ape/config.yml -p 8765 -b 6 --tsv > server_ape.log 2>&1 &
SERVER_PID=$!

sleep 10

python3 $MRT_MARIAN/../scripts/server/client_example.py -p 8765 -b 32 < decode_ape.tsv > server_ape.out
kill $SERVER_PID

# Compare outputs
$MRT_TOOLS/diff.sh server_ape.out decode_ape.expected > server_ape.diff

# Exit with success code
exit 0
