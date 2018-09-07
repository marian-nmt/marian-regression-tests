#!/bin/bash -x

# Exit on error
set -e

if (( $MRT_NUM_DEVICES < 2 )); then
    echo "Too few devices available"
    exit 100
fi

# Test code goes here
rm -rf expsmooth_s2s expsmooth_s2s_*.log
mkdir -p expsmooth_s2s


opts="--no-shuffle --seed 777 --mini-batch 4 --maxi-batch 1 --maxi-batch-sort none --dim-rnn 64 --dim-emb 32 -o sgd --learn-rate 0.5 --valid-sets valid.bpe.en valid.bpe.de --valid-metrics cross-entropy --valid-mini-batch 32 --type s2s"

opt_disp=20
opt_valid=20
opt_finish=200
opt_save=100
opt_exp=0.0001


# Full pass, no exponential-smoothing
$MRT_MARIAN/build/marian \
    -m expsmooth_s2s/model.noexp.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_finish $opts \
    --log expsmooth_s2s_0.log

test -e expsmooth_s2s/model.noexp.npz
test -e expsmooth_s2s_0.log

cat expsmooth_s2s_0.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid' | sed 's/ : Time.*//' > expsmooth_s2s.check
cat expsmooth_s2s_0.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > expsmooth_s2s.valid.check


# Full pass
$MRT_MARIAN/build/marian \
    -m expsmooth_s2s/model.full.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_finish --exponential-smoothing $opt_exp $opts \
    --log expsmooth_s2s_f.log

test -e expsmooth_s2s/model.full.npz
test -e expsmooth_s2s_f.log

cat expsmooth_s2s_f.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid' | sed 's/ : Time.*//' > expsmooth_s2s.expected
cat expsmooth_s2s_f.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > expsmooth_s2s.valid.expected


# A first part of batches
$MRT_MARIAN/build/marian \
    -m expsmooth_s2s/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_save --exponential-smoothing $opt_exp $opts \
    --log expsmooth_s2s_1.log

test -e expsmooth_s2s/model.npz
test -e expsmooth_s2s/model.npz.orig.npz
test -e expsmooth_s2s_1.log

cat expsmooth_s2s_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid' | sed 's/ : Time.*//' > expsmooth_s2s.out
cat expsmooth_s2s_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > expsmooth_s2s.valid.out


# Continue training until full pass
$MRT_MARIAN/build/marian \
    -m expsmooth_s2s/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --valid-freq $opt_valid --after-batches $opt_finish --exponential-smoothing $opt_exp $opts \
    --log expsmooth_s2s_2.log

test -e expsmooth_s2s/model.npz
test -e expsmooth_s2s/model.npz.orig.npz
test -e expsmooth_s2s_2.log

cat expsmooth_s2s_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid'  | sed 's/ : Time.*//' >> expsmooth_s2s.out
cat expsmooth_s2s_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' >> expsmooth_s2s.valid.out


# Results
$MRT_TOOLS/diff-floats.py -p 0.01 expsmooth_s2s.out expsmooth_s2s.expected > expsmooth_s2s.diff
$MRT_TOOLS/diff-floats.py -p 0.01 expsmooth_s2s.valid.out expsmooth_s2s.valid.expected > expsmooth_s2s.valid.diff


# Exit with success code
exit 0
