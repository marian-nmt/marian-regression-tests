#!/bin/bash -x

# Exit on error
set -e

if (( $MRT_NUM_DEVICES < 2 )); then
    echo "Too few devices available"
    exit 100
fi

# Test code goes here
rm -rf adam_sync adam_sync_*.log
mkdir -p adam_sync

# TODO: The weight decaying in the Adam optimizer is disabled, because it gives
# unstable results even for a single GPU trainig, without training restoration.
opts="--no-shuffle --seed 777 --mini-batch 2 --maxi-batch 1 --maxi-batch-sort none --dim-rnn 64 --dim-emb 32 --learn-rate 0.1 --optimizer adam --optimizer-params 0.9 0.98 0 --sync-sgd --devices 0 1"
# Added because default options has changes
opts="$opts --cost-type ce-mean --disp-label-counts false"


# Step 1: Training in one go
$MRT_MARIAN/marian \
    -m adam_sync/model.full.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 $opts \
    --log adam_sync_f.log

test -e adam_sync/model.full.npz
test -e adam_sync_f.log

cat adam_sync_f.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > adam_sync.expected


# Step 2: Training from scratch up to the middle of the training in step 1
$MRT_MARIAN/marian \
    -m adam_sync/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 50 $opts \
    --log adam_sync_1.log

test -e adam_sync/model.npz
test -e adam_sync_1.log

cat adam_sync_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > adam_sync.out


# Step 3: Restore/continue the training from step 2
$MRT_MARIAN/marian \
    -m adam_sync/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 $opts \
    --log adam_sync_2.log

test -e adam_sync/model.npz
test -e adam_sync_2.log

cat adam_sync_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' >> adam_sync.out


# Step 4: Compare log outputs between the full training and partial trainings
$MRT_TOOLS/diff-nums.py -p 0.3 adam_sync.out adam_sync.expected -o adam_sync.diff

# Exit with success code
exit 0
