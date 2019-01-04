#!/bin/bash -x

#####################################################################
# SUMMARY: Test XML decoding with multi-word constrains
# AUTHOR: snukky
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f multiword.{out,diff}

# Run marian decoder
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.de-en.yml --mini-batch 10 -b 3 -n --xml-input --n-best < multiword.in > multiword.out

# Compare the output with the expected output
$MRT_TOOLS/diff-nums.py multiword.out multiword.expected -o multiword.diff

# Exit with success code
exit 0
