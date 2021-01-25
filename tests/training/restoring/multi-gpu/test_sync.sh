#!/bin/bash -x

# Exit on error
set -e

if (( $MRT_NUM_DEVICES < 2 )); then
    echo "Too few devices available"
    exit 100
fi

# Test code goes here
rm -rf sync sync_*.log
mkdir -p sync

opts="--no-shuffle --seed 777 --mini-batch 4 --maxi-batch 1 --maxi-batch-sort none --dim-rnn 64 --dim-emb 32 --optimizer sgd --learn-rate 0.1 --devices 0 1 --sync-sgd"
# Added because default options has changes
opts="$opts --cost-type ce-mean --disp-label-counts false"


$MRT_MARIAN/marian \
    -m sync/model.full.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 $opts \
    --log sync_f.log

test -e sync/model.full.npz
test -e sync_f.log

cat sync_f.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > sync.expected


$MRT_MARIAN/marian \
    -m sync/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 50 $opts \
    --log sync_1.log

test -e sync/model.npz
test -e sync_1.log

cat sync_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > sync.out


$MRT_MARIAN/marian \
    -m sync/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 $opts \
    --log sync_2.log

test -e sync/model.npz
test -e sync_2.log

cat sync_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' >> sync.out

$MRT_TOOLS/diff-nums.py -p 0.3 sync.out sync.expected -o sync.diff

# Exit with success code
exit 0
