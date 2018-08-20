#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf expsmooth_sync expsmooth_sync_*.log
mkdir -p expsmooth_sync


opts="--no-shuffle --seed 777 --mini-batch 4 --maxi-batch 1 --maxi-batch-sort none --dim-rnn 64 --dim-emb 32 -o sgd --learn-rate 0.5 --valid-sets valid.bpe.en valid.bpe.de --valid-metrics cross-entropy --valid-mini-batch 32 --devices 0 1 --sync-sgd"

opt_disp=20
opt_valid=20
opt_finish=200
opt_save=100
opt_exp=0.00001


# Full pass, no exponential-smoothing
$MRT_MARIAN/build/marian \
    -m expsmooth_sync/model.noexp.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_finish $opts \
    --log expsmooth_sync_0.log

test -e expsmooth_sync/model.noexp.npz
test -e expsmooth_sync_0.log

cat expsmooth_sync_0.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid' | sed 's/ : Time.*//' > expsmooth_sync.check
cat expsmooth_sync_0.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > expsmooth_sync.valid.check


# Full pass
$MRT_MARIAN/build/marian \
    -m expsmooth_sync/model.full.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_finish --exponential-smoothing $opt_exp $opts \
    --log expsmooth_sync_f.log

test -e expsmooth_sync/model.full.npz
test -e expsmooth_sync_f.log

cat expsmooth_sync_f.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid' | sed 's/ : Time.*//' > expsmooth_sync.expected
cat expsmooth_sync_f.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > expsmooth_sync.valid.expected


# A first part of batches
$MRT_MARIAN/build/marian \
    -m expsmooth_sync/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_save --exponential-smoothing $opt_exp $opts \
    --log expsmooth_sync_1.log

test -e expsmooth_sync/model.npz
test -e expsmooth_sync/model.npz.orig.npz
test -e expsmooth_sync_1.log

cat expsmooth_sync_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid' | sed 's/ : Time.*//' > expsmooth_sync.out
cat expsmooth_sync_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > expsmooth_sync.valid.out


# Continue training until full pass
$MRT_MARIAN/build/marian \
    -m expsmooth_sync/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_finish --exponential-smoothing $opt_exp $opts \
    --log expsmooth_sync_2.log

test -e expsmooth_sync/model.npz
test -e expsmooth_sync/model.npz.orig.npz
test -e expsmooth_sync_2.log

cat expsmooth_sync_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid'  | sed 's/ : Time.*//' >> expsmooth_sync.out
cat expsmooth_sync_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' >> expsmooth_sync.valid.out


# Results
$MRT_TOOLS/diff-floats.py -p 0.01 expsmooth_sync.out expsmooth_sync.expected > expsmooth_sync.diff
$MRT_TOOLS/diff-floats.py -p 0.01 expsmooth_sync.valid.out expsmooth_sync.valid.expected > expsmooth_sync.valid.diff


# Exit with success code
exit 0
