#!/bin/bash

#####################################################################
# SUMMARY: Decode with a lexical shortlist loading a large number of alternatives
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

rm -f large.{out,diff}

# Run Marian
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/rnn-spm/decode.yml --mini-batch 64 \
    --shortlist $MRT_MODELS/rnn-spm/lex.s2t.gz 20000 20000 \
    < text.in > large.out

$MRT_TOOLS/diff.sh large.out text.expected > large.diff

# Exit with success code
exit 0
