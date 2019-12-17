#!/bin/bash

# Exit on error
set -e

# Skip if requirements are not met
if [ ! $MRT_MARIAN_USE_FBGEMM ]; then
    echo "Marian is not compiled with FBGEMM" 1>&2
    exit 100
elif ! grep -q "avx2" /proc/cpuinfo; then
    echo "Your CPU does not support AVX2, which is required" 1>&2
    exit 100
elif grep -q "avx512" /proc/cpuinfo; then
    echo "Your CPU supports AVX-512, but the test requires AVX2 only" 1>&2
    exit 100
fi

prefix=model_base_fbgemm_packed8_avx2

# Remove previous outputs
rm -f $prefix.out $prefix.bin

# Pack the model
$MRT_MARIAN/marian-conv -f $MRT_MODELS/wngt19/model.base.npz -t $prefix.bin --gemm-type packed8
test -s $prefix.bin

# Run test
$MRT_MARIAN/marian-decoder \
    -m $prefix.bin -v $MRT_MODELS/wngt19/en-de.spm $MRT_MODELS/wngt19/en-de.spm \
    -i newstest2014.in -o $prefix.out \
    -n 0.6 -b 1 --shortlist $MRT_MODELS/wngt19/lex.s2t.gz --skip-cost --cpu-threads 1 \
    --mini-batch 24 --maxi-batch 100 --maxi-batch-sort src -w 512 \
    --max-length 150 --max-length-crop --quiet-translation

# Compare with the expected output
$MRT_TOOLS/diff.sh $prefix.out $prefix.expected > $prefix.diff


# Exit with success code
exit 0
