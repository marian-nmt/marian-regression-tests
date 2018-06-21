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

opts="--no-shuffle --seed 777 --mini-batch 4 --maxi-batch 1 --maxi-batch-sort none --dim-rnn 64 --dim-emb 32 -o sgd --exponential-smoothing 0.1 --learn-rate 0.1 --devices 0 1 --sync-sgd"


$MRT_MARIAN/build/marian \
    -m expsmooth_sync/model.full.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 $opts \
    --log expsmooth_sync_f.log

test -e expsmooth_sync/model.full.npz
test -e expsmooth_sync_f.log

cat expsmooth_sync_f.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > expsmooth_sync.expected


$MRT_MARIAN/build/marian \
    -m expsmooth_sync/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 50 $opts \
    --log expsmooth_sync_1.log

test -e expsmooth_sync/model.npz
test -e expsmooth_sync/model.npz.mvavg.npz
test -e expsmooth_sync_1.log

cat expsmooth_sync_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > expsmooth_sync.out


$MRT_MARIAN/build/marian \
    -m expsmooth_sync/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 $opts \
    --log expsmooth_sync_2.log

test -e expsmooth_sync/model.npz
test -e expsmooth_sync/model.npz.mvavg.npz
test -e expsmooth_sync_2.log

cat expsmooth_sync_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' >> expsmooth_sync.out

$MRT_TOOLS/diff-floats.py -p 0.1 expsmooth_sync.out expsmooth_sync.expected > expsmooth_sync.diff

# Exit with success code
exit 0
