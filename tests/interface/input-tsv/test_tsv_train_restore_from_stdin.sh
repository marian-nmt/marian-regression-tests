#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf restore_stdin restore_stdin*.log
mkdir -p restore_stdin

test -e vocab.de.yml || $MRT_MARIAN/marian-vocab < train.bpe.de > vocab.de.yml
test -e vocab.en.yml || $MRT_MARIAN/marian-vocab < train.bpe.en > vocab.en.yml

# TODO: Weight decaying in Adam is disabled, because it gives unstable results on GPU
extra_opts="--no-shuffle --seed 2222 --maxi-batch 1 --maxi-batch-sort none --mini-batch 16 --dim-emb 128 --dim-rnn 256 --disp-freq 2 --type s2s --sync-sgd --optimizer sgd --cost-type ce-mean"

# Step 1: Train a model in one go, up to the update no. 70, and save training logs
#$MRT_MARIAN/marian \
    #-m restore_stdin/model_full.npz -t train.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    #--cost-type ce-mean --after-batches 60 $extra_opts \
    #--log restore_stdin.log

#test -e restore_stdin/model_full.npz
#test -e restore_stdin.log

#cat restore_stdin.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > restore_stdin.expected

# Step 2: Train a new model from scratch, but only to the update no. 40, and save the model
paste train.bpe.{en,de} | $MRT_MARIAN/marian \
    -m restore_stdin/model.npz -t stdin --tsv -v vocab.en.yml vocab.de.yml \
    --after-batches 40 $extra_opts \
    --log restore_stdin_1.log

test -e restore_stdin/model.npz
test -e restore_stdin_1.log

cat restore_stdin_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > restore_stdin_1.out
cp restore_stdin/model.npz.yml restore_stdin/model.npz.1.yml


# Step 3: Restart the training from step 2 and continue up to the update no. 70, and save training logs
paste train.bpe.{en,de} | $MRT_MARIAN/marian \
    -m restore_stdin/model.npz -t stdin --tsv -v vocab.en.yml vocab.de.yml \
    --after-batches 60 $extra_opts \
    --log restore_stdin_2.log

test -e restore_stdin/model.npz
test -e restore_stdin_2.log


# Step 4: Combine training logs from steps 2 and 3 and compare them with logs from step 1
cat restore_stdin_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > restore_stdin_2.out
cat restore_stdin_1.out restore_stdin_2.out > restore_stdin.out

$MRT_TOOLS/diff-nums.py restore_stdin.out restore_stdin.expected -p 0.1 -o restore_stdin.diff


# Exit with success code
exit 0
