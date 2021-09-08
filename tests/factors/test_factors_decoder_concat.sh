#/bin/bash -x

#####################################################################
# SUMMARY: Tests decoding with factors when combining lemma and factor
# embeddings by concatenating them
# AUTHOR: pedrodiascoelho
# TAGS: factors
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f factors_decoder_concat.{out,diff,log}

# Run marian decoder
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/factors/factors_concat.npz.decoder.yml --log factors_decoder_concat.log < text.in > factors_decoder_concat.out

#checks factors usage
grep -q "Factored embeddings enabled" factors_decoder_concat.log
grep -q "Combining lemma and factors embeddings with concatenation enabled" factors_decoder_concat.log
# Compare the output with the expected output
$MRT_TOOLS/diff.sh factors_decoder_concat.out factors_decoder_concat.expected > factors_decoder_concat.diff

# Exit with success code
exit 0
