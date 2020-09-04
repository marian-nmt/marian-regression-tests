#!/bin/bash -x

#####################################################################
# SUMMARY: Template script for testing Marian server
# AUTHOR: <your-github-username>
#####################################################################

# Exit on error
set -e

# Check if marian-server is compiled
test -f $MRT_MARIAN/marian-server || exit $EXIT_CODE_SKIP

# Make sure the server is not running
clean_up() {
    kill $SERVER_PID
}
trap clean_up EXIT

# Remove old artifacts
rm -f server.{log,out,diff}

# Start marian server
$MRT_MARIAN/marian-server -c $MRT_MODELS/wmt16_systems/marian.en-de.yml -p 8765 > server.log 2>&1 &
SERVER_PID=$!

# Wait for server initialization
sleep 20
grep -q "listening on port" server.log

# Run client
python3 $MRT_MARIAN/../scripts/server/client_example.py -p 8765 < text.in > server.out
kill $SERVER_PID

# Compare the current output with the expected output
$MRT_TOOLS/diff.sh server.out text.expected > server.diff

# Exit with success code
exit 0
