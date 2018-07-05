#!/bin/bash -x

# Exit on error
set -e

if (( $MRT_NUM_DEVICES < 2 )); then
    echo "Too few devices available"
    exit 100
fi

# Test code goes here
rm -rf expsmooth_sync expsmooth_sync_*.log
mkdir -p expsmooth_sync


opts="--no-shuffle --seed 777 --mini-batch 4 --maxi-batch 1 --maxi-batch-sort none --dim-rnn 64 --dim-emb 32 -o sgd --learn-rate 0.5 --valid-sets valid.bpe.en valid.bpe.de --valid-metrics cross-entropy --valid-mini-batch 32 --devices 0 1 --sync-sgd"

# No exponential smoothing
$MRT_MARIAN/build/marian \
    -m expsmooth_sync/model.noexp.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 20 --valid-freq 20 --after-batches 200 $opts \
    --log expsmooth_sync_0.log

test -e expsmooth_sync/model.noexp.npz
test -e expsmooth_sync_0.log

cat expsmooth_sync_0.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid' | sed 's/ : Time.*//' > noexpsmooth_sync.out
#cat expsmooth_sync_0.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > noexpsmooth_sync.valid.out


# With exponential smoothing
$MRT_MARIAN/build/marian \
    -m expsmooth_sync/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 20 --valid-freq 20 --after-batches 200 --exponential-smoothing 0.0001 $opts \
    --log expsmooth_sync.log

test -e expsmooth_sync/model.npz
test -e expsmooth_sync.log

cat expsmooth_sync.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid' | sed 's/ : Time.*//' > expsmooth_sync.out
cat expsmooth_sync.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > expsmooth_sync.valid.out


$MRT_TOOLS/diff-floats.py -p 0.01 expsmooth_sync.out expsmooth_sync.expected > expsmooth_sync.diff
$MRT_TOOLS/diff-floats.py -p 0.01 expsmooth_sync.valid.out expsmooth_sync.valid.expected > expsmooth_sync.valid.diff

# There should be no difference in costs between training w/ and w/o exponential smoothing
$MRT_TOOLS/diff-floats.py -p 0.001 expsmooth_sync.out noexpsmooth_sync.out


# Exit with success code
exit 0
