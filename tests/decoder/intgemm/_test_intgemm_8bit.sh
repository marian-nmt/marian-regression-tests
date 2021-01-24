#!/bin/bash

#####################################################################
# SUMMARY: Decode intgemm 8bit with on-the-fly conversion
# TAGS: cpu student shortlist intgemm
#####################################################################

# Exit on error
set -e

# Skip if requirements are not met
if [ ! $MRT_MARIAN_USE_MKL ]; then
    echo "Marian is not compiled with CPU" 1>&2
    exit 100
elif ! grep -q "avx" /proc/cpuinfo; then
    echo "Your CPU does not support AVX, which is required" 1>&2
    exit 100
fi

# Outputs differ on CPUs supporting AVX AVX2 or AVX512
suffix=avx
if grep -q "avx512_vnni" /proc/cpuinfo; then
    suffix=avx512_vnni
elif grep -q "avx512" /proc/cpuinfo; then
    suffix=avx512
elif grep -q "avx2" /proc/cpuinfo; then
    suffix=avx2
fi

prefix=intgemm_8bit


# Remove previous outputs
rm -f $prefix.out

# Run test
$MRT_MARIAN/marian-decoder \
    -m $MRT_MODELS/student-eten/model.npz -v $MRT_MODELS/student-eten/{vocab.spm,vocab.spm} \
    -i newstest2018.src -o $prefix.out \
    -b 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
    --shortlist $MRT_MODELS/student-eten/lex.s2t 50 50 --cpu-threads 1 \
    --quiet-translation

# Print current and expected BLEU for debugging
python3 $MRT_TOOLS/sacrebleu/sacrebleu.py newstest2018.ref < $prefix.out | tee $prefix.out.bleu
cat $prefix.$suffix.expected.bleu

# Compare with the expected output
$MRT_TOOLS/diff.sh $prefix.out $prefix.$suffix.expected > $prefix.diff


# Exit with success code
exit 0
