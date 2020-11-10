#!/bin/bash -x

#####################################################################
# SUMMARY: Check if the BLEU validation measure equals to the SacreBLEU score
# AUTHOR: snukky
# TAGS: sentencepiece bleu valid-metrics
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf bleu bleu.*{log,out,diff,bleu}
mkdir -p bleu

# Copy the model
cp -r $MRT_MODELS/rnn-spm/model.npz bleu/
test -e bleu/model.npz

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --after-batches 1 --maxi-batch 1 --learn-rate 0 --overwrite \
    -m bleu/model.npz -t $MRT_DATA/europarl.de-en/corpus.small.{de,en}.gz -v $MRT_MODELS/rnn-spm/vocab.{deen,deen}.spm \
    --valid-freq 1 --valid-metrics bleu --valid-sets dev.de dev.en --valid-translation-output bleu.out \
    --beam-size 8 --normalize 1 \
    --log bleu.log

# Check if files exist
test -e bleu/model.npz
test -e bleu.out
test -e bleu.log


# Extract the BLEU score from logs
cat bleu.log | grep ' : bleu : ' | sed -r 's/.* bleu : (.*) : new best.*/\1/' > bleu.score
# Check BLEU from logs
$MRT_TOOLS/diff.sh bleu.score bleu.score.expected > bleu.score.diff


# Run sacreBLEU removing the version information
python3 $MRT_TOOLS/sacrebleu/sacrebleu.py dev.en < bleu.out | sed -r 's/.version[^ ]* / /' > bleu.sacrebleu
# Check BLEU from the validation translation output
$MRT_TOOLS/diff.sh bleu.sacrebleu bleu.sacrebleu.expected > bleu.sacrebleu.diff


# Exit with success code
exit 0
