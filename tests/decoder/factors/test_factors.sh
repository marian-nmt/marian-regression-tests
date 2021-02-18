#/bin/bash -x

#####################################################################
# SUMMARY: Tests decoding with factors
# AUTHOR: pedrodiascoelho
# TAGS: factors
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f factors.{out,diff}

# Run marian decoder
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/factors/model.npz.decoder.yml < text.in > factors.out

# Compare the output with the expected output
$MRT_TOOLS/diff.sh factors.out factors.expected > factors.diff

# Exit with success code
exit 0
