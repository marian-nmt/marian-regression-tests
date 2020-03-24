#!/bin/bash

#####################################################################
# SUMMARY: Translate on CPU using marian-server
# TAGS: cpu rnn server
#####################################################################

# Exit on error
set -e

# Skip if no MKL found
if [ ! $MRT_MARIAN_USE_MKL ]; then
    exit 100
fi

clean_up() {
    kill $SERVER_PID
}
trap clean_up EXIT

head -n 4 text.in > text4.in
head -n 4 text.expected > text4.expected

# Test code goes here
$MRT_MARIAN/marian-server -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -p 8768 --cpu-threads 4 > server_cpu.log 2>&1 &
SERVER_PID=$!

sleep 30

python3 $MRT_MARIAN/../scripts/server/client_example.py -p 8768 < text4.in > text4.cpu.out
kill $SERVER_PID

$MRT_TOOLS/diff.sh text4.cpu.out text4.expected > text4.cpu.diff
test -e server_cpu.log
grep -q "listening on port 8768" server_cpu.log

# Exit with success code
exit 0
