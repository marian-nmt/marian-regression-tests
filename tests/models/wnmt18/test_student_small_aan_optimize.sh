#!/bin/bash

#####################################################################
# SUMMARY: CPU-based optimized decoding with the WNGT18 small student model with AAN
# TAGS: cpu wngt student shortlist obsolete
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
    --mini-batch-words 384 --mini-batch 100 --maxi-batch 100 --maxi-batch-sort src -b1 --optimize \
    --shortlist $MRT_MODELS/wnmt18/lex.s2t 100 75 --skip-cost --cpu-threads=1 --max-length-factor 1.2 \
    > optimize_aan.out

cat optimize_aan.out | perl -pe 's/@@ //g' \
    | $MRT_TOOLS/moses-scripts/scripts/recaser/detruecase.perl \
    | $MRT_TOOLS/moses-scripts/scripts/generic/multi-bleu.perl newstest2014.ref \
    | $MRT_TOOLS/extract-bleu.sh > optimize_aan.bleu

$MRT_TOOLS/diff-nums.py optimize_aan.bleu optimize_aan.bleu.expected -p 0.4 -o optimize_aan.bleu.diff

# Exit with success code
exit 0
