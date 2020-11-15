#!/bin/bash

#####################################################################
# SUMMARY: Decode intgemm 16bit sse2
# TAGS: cpu student shortlist intgemm
#####################################################################

# Exit on error
set -e

# Skip if requirements are not met
if [ ! $MRT_MARIAN_USE_MKL ]; then
    echo "Marian is not compiled with CPU" 1>&2
    exit 100
elif ! grep -q "sse2" /proc/cpuinfo; then
    echo "Your CPU does not support SSE2, which is required" 1>&2
    exit 100
fi

suffix=sse2
prefix=intgemm_16bit


# Remove previous outputs
rm -f $prefix.$suffix.out $prefix.$suffix.bin

# Pack the model
$MRT_MARIAN/marian-conv -f $MRT_MODELS/student-eten/model.npz -t $prefix.$suffix.bin --gemm-type intgemm16$suffix
test -s $prefix.$suffix.bin

# Run test
$MRT_MARIAN/marian-decoder \
    -m $prefix.$suffix.bin -v $MRT_MODELS/student-eten/{vocab.spm,vocab.spm} \
    -i newstest2018.src -o $prefix.$suffix.out \
    -b 1 --mini-batch 32 --maxi-batch 100 --maxi-batch-sort src -w 128 \
    --shortlist $MRT_MODELS/student-eten/lex.s2t 50 50 --cpu-threads 1 \
    --quiet-translation

# Print current and expected BLEU for debugging
python3 $MRT_TOOLS/sacrebleu/sacrebleu.py newstest2018.ref < $prefix.$suffix.out | tee $prefix.$suffix.out.bleu
cat $prefix.$suffix.expected.bleu

# Compare with the expected output
$MRT_TOOLS/diff.sh $prefix.$suffix.out $prefix.$suffix.expected > $prefix.$suffix.diff


# Exit with success code
exit 0
