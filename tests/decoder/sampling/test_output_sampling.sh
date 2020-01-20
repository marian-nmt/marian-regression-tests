#!/bin/bash -x

#####################################################################
# SUMMARY: Basic test for output sampling
# AUTHOR: snukky
# TAGS: sentencepiece sampling decoder
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -f sampl.*{log,out,diff}

# Run marian-decoder
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/rnn-spm/decode.yml -b 1 --output-sampling --seed 1111 \
    --log sampl.log < text.in > sampl.out

test -e sampl.out
test -e sampl.log

# Compare with the expected output
$MRT_TOOLS/diff.sh sampl.out sampl.expected > sampl.diff

# Exit with success code
exit 0
