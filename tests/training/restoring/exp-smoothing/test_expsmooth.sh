#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf expsmooth expsmooth_*.log
mkdir -p expsmooth


opts="--no-shuffle --seed 777 --mini-batch 4 --maxi-batch 1 --maxi-batch-sort none"
opts="$opts --dim-rnn 64 --dim-emb 32 --optimizer sgd --learn-rate 0.5"
opts="$opts --valid-sets valid.bpe.en valid.bpe.de --valid-metrics cross-entropy --valid-mini-batch 32"
# Added because default options has changes
opts="$opts --cost-type ce-mean --disp-label-counts false"

opt_disp=20
opt_valid=20
opt_finish=200
opt_save=100
opt_exp=0.0001


# Full pass, no exponential-smoothing
$MRT_MARIAN/marian \
    -m expsmooth/model.noexp.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_finish $opts \
    --log expsmooth_0.log

test -e expsmooth/model.noexp.npz
test -e expsmooth_0.log

cat expsmooth_0.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid' | sed 's/ : Time.*//' > expsmooth.check
cat expsmooth_0.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > expsmooth.valid.check


# Full pass
$MRT_MARIAN/marian \
    -m expsmooth/model.full.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_finish --exponential-smoothing $opt_exp $opts \
    --log expsmooth_f.log

test -e expsmooth/model.full.npz
test -e expsmooth_f.log

cat expsmooth_f.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid' | sed 's/ : Time.*//' > expsmooth.expected
cat expsmooth_f.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > expsmooth.valid.expected


# A first part of batches
$MRT_MARIAN/marian \
    -m expsmooth/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_save --exponential-smoothing $opt_exp $opts \
    --log expsmooth_1.log

test -e expsmooth/model.npz
test -e expsmooth/model.npz.orig.npz
test -e expsmooth_1.log

cat expsmooth_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid' | sed 's/ : Time.*//' > expsmooth.out
cat expsmooth_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > expsmooth.valid.out


# Continue training until full pass
$MRT_MARIAN/marian \
    -m expsmooth/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_finish --exponential-smoothing $opt_exp $opts \
    --log expsmooth_2.log

test -e expsmooth/model.npz
test -e expsmooth/model.npz.orig.npz
test -e expsmooth_2.log

cat expsmooth_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid'  | sed 's/ : Time.*//' >> expsmooth.out
cat expsmooth_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' >> expsmooth.valid.out


# Results
$MRT_TOOLS/diff-nums.py -p 0.01 expsmooth.out expsmooth.expected -o expsmooth.diff
$MRT_TOOLS/diff-nums.py -p 0.01 expsmooth.valid.out expsmooth.valid.expected -o expsmooth.valid.diff


# Exit with success code
exit 0
