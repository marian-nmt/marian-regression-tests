#/bin/bash -x

#####################################################################
# SUMMARY: Tests decoding with factors
# AUTHOR: pedrodiascoelho
# TAGS: factors
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f factors_decoder.{out,diff,log}

# Run marian decoder
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/factors/model.npz.decoder.yml --log factors_decoder.log < text.in > factors_decoder.out

#checks factors_decoder usage
grep -q "Factored embeddings enabled" factors_decoder.log
grep -q "Factored outputs enabled" factors_decoder.log

# Compare the output with the expected output
$MRT_TOOLS/diff.sh factors_decoder.out factors_decoder.expected > factors_decoder.diff

# Exit with success code
exit 0
