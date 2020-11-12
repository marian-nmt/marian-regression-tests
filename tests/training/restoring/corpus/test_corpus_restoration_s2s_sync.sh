#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf corpus_s2s_sync corpus_s2s_sync*.log
mkdir -p corpus_s2s_sync

test -e vocab.de.yml
test -e vocab.en.yml

# TODO: Weight decaying in Adam is disabled, because it gives unstable results on GPU
extra_opts="--seed 2222 --maxi-batch 1 --maxi-batch-sort none --mini-batch 32 --dim-emb 128 --dim-rnn 256 --disp-freq 4 --type s2s --sync-sgd --optimizer adam --optimizer-params 0.9 0.98 0"
# Added because default options has changes
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"


# Step 1: Train a model in one go, up to the update no. 70, and save training logs
$MRT_MARIAN/marian \
    -m corpus_s2s_sync/model_full.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 70 $extra_opts \
    --log corpus_s2s_sync.log

test -e corpus_s2s_sync/model_full.npz
test -e corpus_s2s_sync.log

cat corpus_s2s_sync.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_s2s_sync.expected


# Step 2: Train a new model from scratch, but only to the update no. 40, and save the model
$MRT_MARIAN/marian \
    -m corpus_s2s_sync/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 40 $extra_opts \
    --log corpus_s2s_sync_1.log

test -e corpus_s2s_sync/model.npz
test -e corpus_s2s_sync_1.log

cat corpus_s2s_sync_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_s2s_sync_1.out
cp corpus_s2s_sync/model.npz.yml corpus_s2s_sync/model.npz.1.yml


# Step 3: Restart the training from step 2 and continue up to the update no. 70, and save training logs
$MRT_MARIAN/marian \
    -m corpus_s2s_sync/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 70 $extra_opts \
    --log corpus_s2s_sync_2.log

test -e corpus_s2s_sync/model.npz
test -e corpus_s2s_sync_2.log


# Step 4: Combine training logs from steps 2 and 3 and compare them with logs from step 1
cat corpus_s2s_sync_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_s2s_sync_2.out
cat corpus_s2s_sync_1.out corpus_s2s_sync_2.out > corpus_s2s_sync.out

$MRT_TOOLS/diff-nums.py corpus_s2s_sync.out corpus_s2s_sync.expected -p 0.1 -o corpus_s2s_sync.diff


# Exit with success code
exit 0
