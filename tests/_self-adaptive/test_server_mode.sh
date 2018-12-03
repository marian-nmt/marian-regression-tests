#!/bin/bash

# Exit on error
set -e

clean_up() {
    kill $SERVER_PID
}
trap clean_up EXIT

# Test code goes here
$MRT_MARIAN/marian-adaptive -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml -p 8766 > server.log 2>&1 &
SERVER_PID=$!

sleep 20

python3 $MRT_MARIAN/../scripts/self-adaptive/client_example.py -p 8766 > text.out
kill $SERVER_PID

test -e server.log
grep -q "listening on port 8766" server.log
grep -q '{"output":"dies ist ein Beispiel' server.log
grep -q "Ep. 2 : Up. 4 : Sen. 2" server.log
grep -q "Ep. 2 : Up. 2 : Sen. 1" server.log 
grep -q "No context" server.log
grep -q 'dies ist ein Beispiel' text.out

# Exit with success code
exit 0
