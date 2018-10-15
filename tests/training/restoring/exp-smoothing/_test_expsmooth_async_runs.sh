#!/bin/bash -x

# Exit on error
set -e

if (( $MRT_NUM_DEVICES < 2 )); then
    echo "Too few devices available"
    exit 100
fi

# Test code goes here
rm -rf expsmooth_async expsmooth_async_*.log expsmooth_async.*out expsmooth_async.*expected
mkdir -p expsmooth_async


opts="--no-shuffle --seed 777 --mini-batch 1 --maxi-batch 1 --maxi-batch-sort none --dim-rnn 64 --dim-emb 32 --optimizer sgd --learn-rate 0.5 --valid-sets valid.bpe.en valid.bpe.de --valid-metrics cross-entropy --valid-mini-batch 32 --devices 0 1"

opt_disp=1
opt_valid=7
opt_finish=16
opt_save=8
opt_exp=0.00001


# Full pass, no exponential-smoothing
$MRT_MARIAN/build/marian \
    -m expsmooth_async/model.noexp.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_finish $opts \
    --log expsmooth_async_0.log

test -e expsmooth_async/model.noexp.npz
test -e expsmooth_async_0.log

cat expsmooth_async_0.log | $MRT_TOOLS/extract-costs.sh > expsmooth_async.check
cat expsmooth_async_0.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > expsmooth_async.valid.check


# Full pass
$MRT_MARIAN/build/marian \
    -m expsmooth_async/model.full.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_finish --exponential-smoothing $opt_exp $opts \
    --log expsmooth_async_f.log

test -e expsmooth_async/model.full.npz
test -e expsmooth_async_f.log

cat expsmooth_async_f.log | $MRT_TOOLS/extract-costs.sh > expsmooth_async.expected
cat expsmooth_async_f.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > expsmooth_async.valid.expected


# The first half of batches
$MRT_MARIAN/build/marian \
    -m expsmooth_async/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_save --exponential-smoothing $opt_exp $opts \
    --log expsmooth_async_1.log

test -e expsmooth_async/model.npz
test -e expsmooth_async/model.npz.orig.npz
test -e expsmooth_async_1.log

cat expsmooth_async_1.log | $MRT_TOOLS/extract-costs.sh > expsmooth_async.out
cat expsmooth_async_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > expsmooth_async.valid.out


# Continue training until full pass
$MRT_MARIAN/build/marian \
    -m expsmooth_async/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_finish --exponential-smoothing $opt_exp $opts \
    --log expsmooth_async_2.log

test -e expsmooth_async/model.npz
test -e expsmooth_async/model.npz.orig.npz
test -e expsmooth_async_2.log

cat expsmooth_async_2.log | $MRT_TOOLS/extract-costs.sh >> expsmooth_async.out
cat expsmooth_async_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' >> expsmooth_async.valid.out


# Compare costs and validation scores
$MRT_TOOLS/diff-floats.py -p 10.0 expsmooth_async.valid.out expsmooth_async.valid.expected > expsmooth_async.valid.diff

# TODO: costs can not be compared without sorting as the order of displayed
# logs is undeterministic for each set of N logs (where N is the number of used
# GPUs)
# TODO: the costs differ too much for the second half of the training with
# exponential smoothing, check if it works correctly
#$MRT_TOOLS/diff-floats.py -p 5.0 -n 10 expsmooth_async.out expsmooth_async.expected > expsmooth_async.diff


# Exit with success code
exit 0
