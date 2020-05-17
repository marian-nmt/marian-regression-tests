#!/bin/bash

#####################################################################
# SUMMARY: Decode the 8-bit WNGT19 model on CPU with AVX2 or AVX512 support
# TAGS: cpu wngt packed student shortlist fbgemm
#####################################################################

# Exit on error
set -e

# Skip if requirements are not met
if [ ! $MRT_MARIAN_USE_FBGEMM ]; then
    echo "Marian is not compiled with FBGEMM" 1>&2
    exit 100
elif ! grep -q "avx2" /proc/cpuinfo; then
    echo "Your CPU does not support AVX2, which is required" 1>&2
    exit 100
fi


# Outputs differ on CPUs supporting AVX2 or AVX512
suffix=avx2
if grep -q "avx512" /proc/cpuinfo; then
    suffix=avx512
fi

prefix=model_base_fbgemm_packed8

# Remove previous outputs
rm -f $prefix.out $prefix.$suffix.bin

# Pack the model
$MRT_MARIAN/marian-conv -f $MRT_MODELS/wngt19/model.base.npz -t $prefix.$suffix.bin --gemm-type packed8$suffix
test -s $prefix.$suffix.bin

# Run test
$MRT_MARIAN/marian-decoder \
    -m $prefix.$suffix.bin -v $MRT_MODELS/wngt19/en-de.spm $MRT_MODELS/wngt19/en-de.spm \
    -i newstest2014.in -o $prefix.out \
    -n 0.6 -b 1 --shortlist $MRT_MODELS/wngt19/lex.s2t.gz --skip-cost --cpu-threads 1 \
    --mini-batch 24 --maxi-batch 100 --maxi-batch-sort src -w 512 \
    --max-length 150 --max-length-crop --quiet-translation

# Print current and expected BLEU for debugging
python3 $MRT_TOOLS/sacrebleu/sacrebleu.py newstest2014.ref < $prefix.out | tee $prefix.out.bleu
cat $prefix.$suffix.expected.bleu

# Compare with the expected output
$MRT_TOOLS/diff.sh $prefix.out $prefix.$suffix.expected > $prefix.diff


# Exit with success code
exit 0
