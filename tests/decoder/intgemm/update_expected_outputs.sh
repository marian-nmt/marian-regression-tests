#!/bin/bash

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

[[ $# -eq 1 ]] || (echo "This script must take avx/avx2/avx512 as the first argument" && exit 1)

avx=$1

for suffix in '' .bleu; do
    test -f intgemm_16bit.$avx.expected        && cp intgemm_16bit.out$suffix        intgemm_16bit.$avx.expected$suffix
    test -f intgemm_8bit.$avx.expected         && cp intgemm_8bit.out$suffix         intgemm_8bit.$avx.expected$suffix

    test -f intgemm_16bit.sse2.expected        && cp intgemm_16bit.sse2.out$suffix   intgemm_16bit.sse2.expected$suffix
    test -f intgemm_8bit.ssse3.expected        && cp intgemm_8bit.ssse3.out$suffix   intgemm_8bit.ssse3.expected$suffix

    #test -f fbgemm_intgemm_8bit.$avx.expected  && cp fbgemm_intgemm_8bit.out$suffix  fbgemm_intgemm_8bit.$avx.expected$suffix
    #test -f intgemm_8bit_shifted.$avx.expected && cp intgemm_8bit_shifted.out$suffix intgemm_8bit_shifted.$avx.expected$suffix
done
