#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf adam_2e adam_1st_epoch.log adam_2nd_epoch.log adam_two_epochs.log
mkdir -p adam_2e

extra_opts="--no-shuffle --seed 1111 --maxi-batch 1 --maxi-batch-sort none --mini-batch 32 --dim-emb 64 --dim-rnn 128 --disp-freq 4 --save-freq 32 -l 0.1 --optimizer adam"


## Uncomment to update the test
#$MRT_MARIAN/build/marian $extra_opts \
    #-m adam_2e/model_2e.npz -t train.max50.{en,de} -v vocab.{en,de}.yml --after-epoch 2 \
    #--log adam_two_epochs.log

#cat adam_two_epochs.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. 1" | sed 's/ : Time.*//' > adam_2e_1st.expected
#cat adam_two_epochs.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. 2" | sed 's/ : Time.*//' > adam_2e_2nd.expected


$MRT_MARIAN/build/marian \
$MRT_MARIAN/build/marian $extra_opts \
    -m adam_2e/model.npz -t train.max50.{en,de} -v vocab.{en,de}.yml --after-epoch 1 \
    --log adam_1st_epoch.log

test -e adam_2e/model.npz
test -e adam_1st_epoch.log

cat adam_1st_epoch.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > adam_1st_epoch.out
cp adam_2e/model.npz.yml adam_2e/model.npz.1st_epoch.yml

$MRT_MARIAN/build/marian $extra_opts \
    -m adam_2e/model.npz -t train.max50.{en,de} -v vocab.{en,de}.yml --after-epoch 2 \
    --log adam_2nd_epoch.log

test -e adam_2e/model.npz
test -e adam_2nd_epoch.log

cat adam_2nd_epoch.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > adam_2nd_epoch.out

$MRT_TOOLS/diff-floats.py adam_1st_epoch.out adam_2e_1st.expected -p 0.01 > adam_2e_1st.diff
$MRT_TOOLS/diff-floats.py adam_2nd_epoch.out adam_2e_2nd.expected -p 0.1 > adam_2e_2nd.diff

# Exit with success code
exit 0
