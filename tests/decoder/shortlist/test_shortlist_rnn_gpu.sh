#!/bin/bash

#####################################################################
# SUMMARY: Decode with a lexical shortlist on GPU
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

rm -f rnn_gpu.{out,diff}

# Run Marian
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/rnn-spm/decode.yml --mini-batch 64 \
    --shortlist $MRT_MODELS/rnn-spm/lex.s2t.gz 100 75 \
    < text.in > rnn_gpu.out

$MRT_TOOLS/diff.sh rnn_gpu.out rnn_gpu.expected > rnn_gpu.diff

# Exit with success code
exit 0
