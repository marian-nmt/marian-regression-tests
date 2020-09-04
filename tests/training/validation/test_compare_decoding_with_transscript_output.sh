#!/bin/bash -x

#####################################################################
# SUMMARY: Check if the in-validation translation and standard decoding give the same output
# AUTHOR: snukky
# TAGS: valid valid-script transformer
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf compare-trans compare-trans.*{log,out,diff,bleu}
mkdir -p compare-trans

# Copy the model
cp -r $MRT_MODELS/transformer/model.npz compare-trans/
test -e compare-trans/model.npz

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --after-batches 1 --maxi-batch 1 --learn-rate 0 --overwrite \
    -m compare-trans/model.npz -t $MRT_DATA/europarl.de-en/corpus.small.{de,en}.gz -v $MRT_MODELS/transformer/vocab.{ende,ende}.yml \
    --valid-freq 1 --valid-metrics translation --valid-sets dev.bpe.en dev.bpe.de --valid-script-path "bash compare-trans.sh" --valid-translation-output compare-trans.out \
    --valid-script-args "$MRT_TOOLS" \
    --beam-size 4 --normalize 1 \
    --log compare-trans.log

# Check if files exist
test -e compare-trans/model.npz
test -e compare-trans/model.npz.decoder.yml
test -e compare-trans.out
test -e compare-trans.log

# Extract the BLEU score from logs
cat compare-trans.log | grep ' : translation : ' | sed -r 's/.* translation : (.*) : new best.*/\1/' > compare-trans.bleu
# Check BLEU from logs
$MRT_TOOLS/diff.sh compare-trans.bleu compare-trans.bleu.expected > compare-trans.bleu.diff

# Decode
$MRT_MARIAN/marian-decoder \
    -c compare-trans/model.npz.decoder.yml --mini-batch 32 --beam-size 4 --normalize 1 \
    -i dev.bpe.en -o compare-trans.decoder.out

# Compare outputs from the in-training translation and the decoding outside the training
$MRT_TOOLS/diff.sh compare-trans.out compare-trans.decoder.out | tee compare-trans.decoder.diff

# Exit with success code
exit 0

