#!/bin/bash -x

# Script for re-generatting expected outputs and BLEU scores for CPUs with
# avx/avx2/avx512 architectures after running regression tests.
#
# On Valhalla the machines could be gna/hodor/sigyn, respectively.
#
# An example scenario on hodor:
#    1. Compile Marian with -DUSE_FBGEMM=on -DUSE_SENTENCEPIECE-on on hodor
#    2. Run regression tests, which fail due to updates in intgemm
#    3. Run `bash update_expected_outputs.sh avx2` from this directory
#    4. Add and commit *.expected* files

[[ $# -ne 1 ]] && { echo "This script must take avx/avx2/avx512 as the first argument"; exit 1; }

avx=$1

for suffix in '' .bleu; do
    cp intgemm_16bit.out$suffix        intgemm_16bit.$avx.expected$suffix
    cp intgemm_8bit.out$suffix         intgemm_8bit.$avx.expected$suffix

    cp intgemm_16bit_sse2.out$suffix   intgemm_16bit_sse2.$avx.expected$suffix
    cp intgemm_8bit_ssse3.out$suffix   intgemm_8bit_ssse3.$avx.expected$suffix
    cp intgemm_16bit_avx2.out$suffix   intgemm_16bit_avx2.$avx.expected$suffix
    cp intgemm_8bit_avx2.out$suffix    intgemm_8bit_avx2.$avx.expected$suffix

    #cp fbgemm_intgemm_8bit.out$suffix  fbgemm_intgemm_8bit.$avx.expected$suffix
    #cp intgemm_8bit_shifted.out$suffix intgemm_8bit_shifted.$avx.expected$suffix
done
