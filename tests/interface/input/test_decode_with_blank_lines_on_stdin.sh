#!/bin/bash -x

#####################################################################
# SUMMARY: Translate from STDIN with empty lines
# AUTHOR: snukky
# TAGS: emptyline sentencepiece
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f blank_decode_stdin.{out,diff}

# Run marian decoder
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/rnn-spm/decode.yml -b 3 < text_blank_lines.in > blank_decode_stdin.out

# Compare the output with the expected output
$MRT_TOOLS/diff.sh blank_decode_stdin.out blank_decode.expected > blank_decode_stdin.diff

# Exit with success code
exit 0
