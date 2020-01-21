#!/bin/bash

#####################################################################
# SUMMARY: Decode with a lexical shortlist on CPU
# TAGS: cpu shortlist sentencepiece rnn
#####################################################################

# Exit on error
set -e

rm -f rnn_cpu.{out,diff}

# Run Marian
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/rnn-spm/decode.yml --mini-batch 16 --cpu-threads 4 \
    --shortlist $MRT_MODELS/rnn-spm/lex.s2t.gz 100 75 \
    < text.in > rnn_cpu.out

$MRT_TOOLS/diff.sh rnn_cpu.out rnn_cpu.expected > rnn_cpu.diff

# Exit with success code
exit 0
