#!/bin/bash -x

#####################################################################
# SUMMARY: Check if the BLEU-detok validation measure equals to the SacreBLEU score
# AUTHOR: snukky
# TAGS: sentencepiece bleu-detok
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf bleu-detok bleu-detok.*{log,out,diff,bleu}
mkdir -p bleu-detok

# Copy the model
cp -r $MRT_MODELS/rnn-spm/model.npz bleu-detok/
test -e bleu-detok/model.npz

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --after-batches 1 --maxi-batch 1 --learn-rate 0 --overwrite \
    -m bleu-detok/model.npz -t $MRT_DATA/europarl.de-en/corpus.small.{de,en}.gz -v $MRT_MODELS/rnn-spm/vocab.{deen,deen}.spm \
    --valid-freq 1 --valid-metrics bleu-detok --valid-sets dev.de dev.en --valid-translation-output bleu-detok.out \
    --beam-size 8 --normalize 1 \
    --log bleu-detok.log

# Check if files exist
test -e bleu-detok/model.npz
test -e bleu-detok.out
test -e bleu-detok.log


# Extract the BLEU score from logs
cat bleu-detok.log | grep ' : bleu-detok : ' | sed -r 's/.* bleu-detok : (.*) : new best.*/\1/' > bleu-detok.bleu
# Check BLEU from logs
$MRT_TOOLS/diff.sh bleu-detok.bleu bleu-detok.bleu.expected > bleu-detok.bleu.diff


# Run sacreBLEU removing the version information
$MRT_TOOLS/sacrebleu/sacrebleu.py dev.en < bleu-detok.out | sed -r 's/.version[^ ]* / /' > bleu-detok.sacrebleu
# Check BLEU from the validation translation output 
$MRT_TOOLS/diff.sh bleu-detok.sacrebleu bleu-detok.sacrebleu.expected > bleu-detok.sacrebleu.diff


# Exit with success code
exit 0
