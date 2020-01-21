#!/bin/bash

#####################################################################
# SUMMARY: CPU-based decoding with the WNGT18 small student model with AAN
# TAGS: cpu wngt student shortlist
#####################################################################

# Exit on error
set -e

# Skip if no MKL found
if [ ! $MRT_MARIAN_USE_MKL ]; then
    exit 100
fi

model=model.student.small.aan

# Run test
cat newstest2014.in | $MRT_MARIAN/marian-decoder \
    -m $MRT_MODELS/wnmt18/$model/model.npz \
    -v $MRT_MODELS/wnmt18/vocab.ende.{yml,yml} \
    --mini-batch-words 384 --mini-batch 100 --maxi-batch 100 --maxi-batch-sort src -b 1 \
    --shortlist $MRT_MODELS/wnmt18/lex.s2t 100 75 --cpu-threads=1 --skip-cost --max-length-factor 1.2 \
    > student_small_aan.out

$MRT_TOOLS/diff.sh student_small_aan.out student_small_aan.expected > student_small_aan.diff

# Exit with success code
exit 0
