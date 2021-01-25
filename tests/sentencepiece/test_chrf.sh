#!/bin/bash -x

#####################################################################
# SUMMARY: Check if the ChrF validation measure equals to the SacreBLEU score
# AUTHOR: snukky
# TAGS: sentencepiece chrf valid-metrics
#####################################################################

# Exit on error
set -e

# Remove old artifacts and create working directory
rm -rf chrf chrf.*{log,out,diff,score}
mkdir -p chrf

# Copy the model
cp -r $MRT_MODELS/rnn-spm/model.npz chrf/
test -e chrf/model.npz

# Run marian command
$MRT_MARIAN/marian \
    --no-shuffle --after-batches 1 --maxi-batch 1 --learn-rate 0 --overwrite \
    -m chrf/model.npz -t $MRT_DATA/europarl.de-en/corpus.small.{de,en}.gz -v $MRT_MODELS/rnn-spm/vocab.{deen,deen}.spm \
    --valid-freq 1 --valid-metrics chrf --valid-sets dev.de dev.en --valid-translation-output chrf.out \
    --beam-size 8 --normalize 1 \
    --log chrf.log

# Check if files exist
test -e chrf/model.npz
test -e chrf.out
test -e chrf.log


# Extract the score from logs
cat chrf.log | grep ' : chrf : ' | sed -r 's/.* chrf : (.*) : new best.*/\1/' > chrf.score
# Check score from logs
$MRT_TOOLS/diff.sh chrf.score chrf.score.expected > chrf.score.diff


# Run sacreBLEU removing the version information
python3 $MRT_TOOLS/sacrebleu/sacrebleu.py dev.en < chrf.out | sed -r 's/.version[^ ]* / /' > chrf.sacrebleu
# Check BLEU from the validation translation output
$MRT_TOOLS/diff.sh chrf.sacrebleu chrf.sacrebleu.expected > chrf.sacrebleu.diff


# Exit with success code
exit 0
