#!/bin/bash

#####################################################################
# SUMMARY: Translate using marian-server
# TAGS: server
#####################################################################

# Exit on error
set -e

clean_up() {
    kill $SERVER_PID
}
trap clean_up EXIT

# Test code goes here
$MRT_MARIAN/marian-server -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -p 8765 > server.log 2>&1 &
SERVER_PID=$!

sleep 20

python3 $MRT_MARIAN/../scripts/server/client_example.py -p 8765 < text.in > text.out
kill $SERVER_PID

$MRT_TOOLS/diff.sh text.out text.expected > text.diff
test -e server.log
grep -q "listening on port 8765" server.log

# Exit with success code
exit 0
