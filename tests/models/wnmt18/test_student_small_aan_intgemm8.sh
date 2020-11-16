#!/bin/bash

#####################################################################
# SUMMARY: CPU-based optimized decoding with the WNGT18 small student model with AAN and intgemm 8bit
# TAGS: cpu wngt student shortlist intgemm
#####################################################################

# Exit on error
set -e

# Skip if no MKL found
if [ ! $MRT_MARIAN_USE_MKL ]; then
    exit 100
fi

model=model.student.small.aan

# Remove previous outputs
rm -f optimize_aan_8.out $model.intgemm8.bin

# Pack the model
$MRT_MARIAN/marian-conv -f $MRT_MODELS/wnmt18/$model/model.npz -t $model.intgemm8.bin --gemm-type intgemm8
test -s $model.intgemm8.bin

# Run test
cat newstest2014.in | $MRT_MARIAN/marian-decoder \
    -m $model.intgemm8.bin \
    -v $MRT_MODELS/wnmt18/vocab.ende.{yml,yml} \
    --mini-batch-words 384 --mini-batch 100 --maxi-batch 100 --maxi-batch-sort src -b1 \
    --shortlist $MRT_MODELS/wnmt18/lex.s2t 100 75 --skip-cost --cpu-threads=1 --max-length-factor 1.2 \
    > optimize_aan_8.out

cat optimize_aan_8.out | perl -pe 's/@@ //g' \
    | $MRT_TOOLS/moses-scripts/scripts/recaser/detruecase.perl \
    | $MRT_TOOLS/moses-scripts/scripts/generic/multi-bleu.perl newstest2014.ref \
    | $MRT_TOOLS/extract-bleu.sh > optimize_aan_8.bleu

$MRT_TOOLS/diff-nums.py optimize_aan_8.bleu optimize_aan.bleu.expected -p 0.6 -o optimize_aan_8.bleu.diff

# Exit with success code
exit 0
