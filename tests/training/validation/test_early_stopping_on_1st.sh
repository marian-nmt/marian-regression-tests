#!/bin/bash -x

#####################################################################
# SUMMARY: Test early stopping after stalling on the first validation metric
# AUTHOR: snukky
# TAGS: valid valid-script
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf stop_on_1st stop_on_1st.log stop_on_script.temp
mkdir -p stop_on_1st

# Start training with a fully trained model so that validation metrics do not improve easily
cp $MRT_MODELS/wngt19/model.small.npz stop_on_1st/model.npz

test -s devset.en || head -n 50 $MRT_MODELS/wngt19/newstest2014.en | sed -r 's/@@ //g' > devset.en
test -s devset.de || head -n 50 $MRT_MODELS/wngt19/newstest2014.de | sed -r 's/@@ //g' > devset.de

# Training sides are intentionaly reversed to test early stopping
$MRT_MARIAN/marian \
    --seed 2222 --no-shuffle --clip-norm 1 --maxi-batch 1 --mini-batch 32 -w 2500 \
    -m stop_on_1st/model.npz -t $MRT_DATA/europarl.de-en/corpus.small.{de,en}.gz \
    -v $MRT_MODELS/wngt19/en-de.{spm,spm} \
    --disp-freq 5 --valid-freq 10 --after-batches 200 \
    --valid-metrics valid-script ce-mean-words \
    --valid-script-path ./stop_on_script.sh \
    --valid-sets $MRT_DATA/europarl.de-en/toy.bpe.{en,de} \
    --valid-log stop_on_1st.log \
    --early-stopping 4 --early-stopping-on first

test -e stop_on_1st/model.npz
test -e stop_on_1st/model.npz.yml
test -e stop_on_1st.log

$MRT_TOOLS/strip-timestamps.sh < stop_on_1st.log | grep '\[valid\]' > stop_on_1st.out
$MRT_TOOLS/diff-nums.py stop_on_1st.out stop_on_1st.expected -p 0.2 -o stop_on_1st.diff

# Exit with success code
exit 0
