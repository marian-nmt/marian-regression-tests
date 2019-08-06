#!/bin/bash -x

#####################################################################
# SUMMARY: Run marian-scorer with non-existent SentencePiece vocabulary
# AUTHOR: snukky
# TAGS: sentencepiece
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf score_wo_vocab.{log,out}

# Run marian-decoder
$MRT_MARIAN/marian-scorer -m $MRT_MODELS/transformer/model.npz -v foo.spm foo.spm \
    -t text.in text.ref > score_wo_vocab.log 2>&1 || true

# Check if files exist
test -e score_wo_vocab.log

# Check logging messages
grep -qi "vocabulary file .*does not exist" score_wo_vocab.log

# Exit with success code
exit 0
