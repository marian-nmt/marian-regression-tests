#!/bin/bash -x

#####################################################################
# SUMMARY:
# TAGS: mini-batch-fit
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf corpus_fit corpus_fit*.log
mkdir -p corpus_fit

test -e vocab.de.yml
test -e vocab.en.yml

extra_opts="--seed 5555 --maxi-batch 8 --maxi-batch-sort src --mini-batch 32 --mini-batch-fit -w 100 --optimizer sgd --dim-emb 128 --dim-rnn 256 --disp-freq 4"
# Added because default options has changes
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"


# Step 1: Train a model in one go, up to the update no. 70, and save training logs
$MRT_MARIAN/marian \
    -m corpus_fit/model_full.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 80 $extra_opts \
    --log corpus_fit.log

test -e corpus_fit/model_full.npz
test -e corpus_fit.log

cat corpus_fit.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_fit.expected


# Step 2: Train a new model from scratch, but only to the update no. 40, and save the model
$MRT_MARIAN/marian \
    -m corpus_fit/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 60 $extra_opts \
    --log corpus_fit_1.log

test -e corpus_fit/model.npz
test -e corpus_fit_1.log

cat corpus_fit_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_fit_1.out
cp corpus_fit/model.npz.yml corpus_fit/model.npz.1.yml
cp corpus_fit/model.npz.progress.yml corpus_fit/model.npz.progress.1.yml


# Step 3: Restart the training from step 2 and continue up to the update no. 70, and save training logs
$MRT_MARIAN/marian \
    -m corpus_fit/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 80 $extra_opts \
    --log corpus_fit_2.log

test -e corpus_fit/model.npz
test -e corpus_fit_2.log


# Step 4: Combine training logs from steps 2 and 3 and compare them with logs from step 1
cat corpus_fit_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_fit_2.out
cat corpus_fit_1.out corpus_fit_2.out > corpus_fit.out

$MRT_TOOLS/diff-nums.py corpus_fit.out corpus_fit.expected -p 0.1 -o corpus_fit.diff


# Exit with success code
exit 0
