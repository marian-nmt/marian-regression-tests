#!/bin/bash -x

#####################################################################
# SUMMARY: Test early stopping with epsilon after stalling on every validation metrics
# AUTHOR: snukky
# TAGS: valid valid-script early-stopping early-stopping-epsilon
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf eps_stop_on_all eps_stop_on_all.log eps_stop_script.temp
mkdir -p eps_stop_on_all

# Start training with a fully trained model so that validation metrics do not improve easily
cp $MRT_MODELS/wngt19/model.small.npz eps_stop_on_all/model.npz

test -s devset.en || head -n 50 $MRT_MODELS/wngt19/newstest2014.en | sed -r 's/@@ //g' > devset.en
test -s devset.de || head -n 50 $MRT_MODELS/wngt19/newstest2014.de | sed -r 's/@@ //g' > devset.de

# Training sides are intentionaly reversed to test early stopping
$MRT_MARIAN/marian \
    --seed 2222 --no-shuffle --clip-norm 1 --maxi-batch 1 --mini-batch 32 -w 2500 \
    -m eps_stop_on_all/model.npz -t $MRT_DATA/europarl.de-en/corpus.small.{de,en}.gz \
    -v $MRT_MODELS/wngt19/en-de.{spm,spm} \
    --disp-freq 5 --valid-freq 10 --after-batches 200 \
    --valid-metrics ce-mean-words valid-script \
    --valid-script-path ./eps_stop_script.sh \
    --valid-sets devset.{en,de} \
    --valid-log eps_stop_on_all.log \
    --early-stopping 4 --early-stopping-epsilon -0.2 0.4 --early-stopping-on all

test -e eps_stop_on_all/model.npz
test -e eps_stop_on_all/model.npz.yml
test -e eps_stop_on_all.log

$MRT_TOOLS/strip-timestamps.sh < eps_stop_on_all.log | grep '\[valid\]' > eps_stop_on_all.out
$MRT_TOOLS/diff-nums.py eps_stop_on_all.out eps_stop_on_all.expected -p 0.2 -o eps_stop_on_all.diff

# Exit with success code
exit 0
