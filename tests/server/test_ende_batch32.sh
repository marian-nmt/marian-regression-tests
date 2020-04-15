#!/bin/bash

#####################################################################
# SUMMARY: Translate with mini-batch 32 using marian-server
# TAGS: server
#####################################################################

# Exit on error
set -e

clean_up() {
    kill $SERVER_PID
}
trap clean_up EXIT

# Test code goes here
$MRT_MARIAN/marian-server -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -p 8766 \
    --mini-batch 32 --maxi-batch 1 > server.b32.log 2>&1 &
SERVER_PID=$!

sleep 20

python3 $MRT_MARIAN/../scripts/server/client_example.py -p 8766 -b 32 < text.in > text.b32.out
kill $SERVER_PID
$MRT_TOOLS/diff.sh text.b32.out text.expected > text.diff

# Exit with success code
exit 0
