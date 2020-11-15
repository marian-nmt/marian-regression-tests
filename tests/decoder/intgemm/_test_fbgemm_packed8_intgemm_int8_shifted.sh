#!/bin/bash

#####################################################################
# SUMMARY: Decode fbgemm + intgemm 8bit shifted for the output layer
# TAGS: cpu student shortlist intgemm fbgemm
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

# Outputs differ on CPUs supporting AVX AVX2 or AVX512
suffix=avx2
if grep -q "avx512_vnni" /proc/cpuinfo; then
    suffix=avx512_vnni
elif grep -q "avx512" /proc/cpuinfo; then
    suffix=avx512
fi

prefix=fbgemm_intgemm_8bit_shifted
prefix_ref=fbgemm_intgemm_8bit


# Remove previous outputs
rm -f $prefix.out $prefix.$suffix.bin

# Pack the model
$MRT_MARIAN/marian-conv -f $MRT_MODELS/student-eten/model.npz -t $prefix.$suffix.bin --gemm-type packed8$suffix
test -s $prefix.$suffix.bin

# Run test
$MRT_MARIAN/marian-decoder \
    -m $prefix.$suffix.bin -v $MRT_MODELS/student-eten/{vocab.spm,vocab.spm} \
    -i newstest2018.src -o $prefix.out \
    -b 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
    --shortlist $MRT_MODELS/student-eten/lex.s2t 50 50 --cpu-threads 1 --int8shift \
    --quiet-translation

# Print current and expected BLEU for debugging
python3 $MRT_TOOLS/sacrebleu/sacrebleu.py newstest2018.ref < $prefix.out | tee $prefix.out.bleu
cat $prefix_ref.$suffix.expected.bleu

# Compare with the expected output
$MRT_TOOLS/diff.sh $prefix.out $prefix_ref.$suffix.expected > $prefix.diff


# Exit with success code
exit 0
