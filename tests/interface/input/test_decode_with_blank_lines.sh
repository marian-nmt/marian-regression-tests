#!/bin/bash -x

#####################################################################
# SUMMARY: Translate an input file with empty lines
# AUTHOR: snukky
# TAGS: emptyline sentencepiece
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f blank_decode.{out,diff}

# Run marian decoder
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/rnn-spm/decode.yml -b 3 -i text_blank_lines.in -o blank_decode.out

# Compare the output with the expected output
$MRT_TOOLS/diff.sh blank_decode.out blank_decode.expected > blank_decode.diff

# Exit with success code
exit 0
