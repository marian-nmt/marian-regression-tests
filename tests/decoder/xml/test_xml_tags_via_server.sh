#!/bin/bash -x

#####################################################################
# SUMMARY: Test different variants of XML tags via web server
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

clean_up() {
    kill $SERVER_PID
}
trap clean_up EXIT

# Remove old artifacts
rm -f server.{out,diff}

# Run marian server
$MRT_MARIAN/marian-server -c $MRT_MODELS/wmt16_systems/marian.de-en.yml -p 7766 -b 2 -n --xml-input > server.log 2>&1 &
SERVER_PID=$!

sleep 15

python3 $MRT_MARIAN/../scripts/server/client_example.py -p 7766 < tags.in > server.out
kill $SERVER_PID

# Compare the output with the expected output
$MRT_TOOLS/diff.sh server.out tags.expected > server.diff
test -e server.log
grep -q "listening on port 7766" server.log

