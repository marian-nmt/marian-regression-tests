#!/bin/bash

# Exit on error
set -eo pipefail

clean_up() {
    kill $SERVER_PID
}
trap clean_up EXIT

# Test code goes here
$MRT_MARIAN/build/marian-server -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -p 8765 \
    --alignment > server.align.log 2>&1 &
SERVER_PID=$!

sleep 20

python3 $MRT_MARIAN/scripts/server/client_example.py -p 8765 < text.in > text.align.out
kill $SERVER_PID

diff $(pwd)/text.align.out $(pwd)/text.align.expected | tee $(pwd)/text.align.diff | head

# Exit with success code
exit 0
