#!/bin/bash -x

#####################################################################
# SUMMARY: Test learning rate decaying after stalled validation
# AUTHOR: snukky
# TAGS: valid valid-script lr-decay
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf lrdecay_stalled_all lrdecay_stalled_all.log valid_script.temp
mkdir -p lrdecay_stalled_all

# Start training with a fully trained model so that validation metrics do not improve easily
cp $MRT_MODELS/wngt19/model.small.npz lrdecay_stalled_all/model.npz

test -s devset.en || head -n 50 $MRT_MODELS/wngt19/newstest2014.en | sed -r 's/@@ //g' > devset.en
test -s devset.de || head -n 50 $MRT_MODELS/wngt19/newstest2014.de | sed -r 's/@@ //g' > devset.de

# Training sides are intentionaly reversed to test early stopping
$MRT_MARIAN/marian \
    --seed 2222 --no-shuffle --clip-norm 1 --maxi-batch 1 --mini-batch 32 -w 2500 \
    -m lrdecay_stalled_all/model.npz -t $MRT_DATA/europarl.de-en/corpus.small.{de,en}.gz \
    -v $MRT_MODELS/wngt19/en-de.{spm,spm} \
    --disp-freq 5 --valid-freq 10 --after-batches 200 \
    --valid-metrics ce-mean-words valid-script \
    --valid-script-path ./valid_script.sh \
    --valid-sets devset.{en,de} \
    --log lrdecay_stalled_all.log \
    --lr-decay 0.9 --lr-decay-start 1 --lr-decay-strategy stalled \
    --early-stopping 4 --early-stopping-on all

test -e lrdecay_stalled_all/model.npz
test -e lrdecay_stalled_all/model.npz.yml
test -e lrdecay_stalled_all.log

$MRT_TOOLS/strip-timestamps.sh < lrdecay_stalled_all.log | grep -P '(\[valid\]|Decaying)' > lrdecay_stalled_all.out
$MRT_TOOLS/diff-nums.py lrdecay_stalled_all.out lrdecay_stalled_all.expected -p 0.2 -o lrdecay_stalled_all.diff

# Exit with success code
exit 0
