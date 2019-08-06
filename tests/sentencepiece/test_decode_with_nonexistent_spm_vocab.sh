#!/bin/bash -x

#####################################################################
# SUMMARY: Run marian-decoder with non-existent SentencePiece vocabulary
# AUTHOR: snukky
# TAGS: sentencepiece
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf decode_wo_vocab.{log,out}

# Run marian-decoder
$MRT_MARIAN/marian-decoder -m $MRT_MODELS/transformer/model.npz -v foo.spm foo.spm \
    < text.in > decode_wo_vocab.log 2>&1 || true

# Check if files exist
test -e decode_wo_vocab.log

# Check logging messages
grep -qi "vocabulary file .*does not exist" decode_wo_vocab.log

# Exit with success code
exit 0
