#!/bin/bash -x

#####################################################################
# SUMMARY: Re-score files with empty lines
# AUTHOR: snukky
# TAGS: emptyline sentencepiece scorer
#####################################################################

# Exit on error
set -e

# Remove old artifacts
rm -f blank_score.{out,diff}

# Run marian scorer
$MRT_MARIAN/marian-scorer -c $MRT_MODELS/rnn-spm/score.yml -t text_blank_lines.{in,ref} > blank_score.out

# Compare the output with the expected output
$MRT_TOOLS/diff-nums.py blank_score.out blank_score.expected > blank_score.diff

# Exit with success code
exit 0
