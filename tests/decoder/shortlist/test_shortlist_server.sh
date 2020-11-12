#!/bin/bash

#####################################################################
# SUMMARY: Decode with a lexical shortlist on GPU via marian-server
# AUTHOR: snukky
# TAGS: server
#####################################################################

# Exit on error
set -e

# Check if marian-server is compiled
test -f $MRT_MARIAN/marian-server || exit $EXIT_CODE_SKIP

clean_up() {
    kill $SERVER_PID
}
trap clean_up EXIT

rm -f server.{out,diff}

# Start Marian server
$MRT_MARIAN/marian-server -c $MRT_MODELS/rnn-spm/decode.yml --shortlist $MRT_MODELS/rnn-spm/lex.s2t.gz 100 75 -p 8765 --mini-batch 64 > server.log 2>&1 &
SERVER_PID=$!

# Wait a bit until the model is loaded
sleep 20

# Translate
python3 $MRT_MARIAN/../scripts/server/client_example.py -p 8765 -b 64 < text.in > server.out
kill $SERVER_PID

# Compare the translation with expected output
$MRT_TOOLS/diff.sh server.out rnn_gpu.expected > server.diff
test -e server.log
grep -q "listening on port 8765" server.log

# Exit with success code
exit 0
