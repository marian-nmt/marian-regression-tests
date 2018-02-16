#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf adam_sync adam_sync*.log
mkdir -p adam_sync

if (( $MRT_NUM_DEVICES < 2 )); then
    echo "Too few devices available"
    exit 100
fi

$MRT_MARIAN/build/marian \
    --no-shuffle --seed 7777 --maxi-batch 1 --maxi-batch-sort none --mini-batch 32 --dim-emb 128 --dim-rnn 256 \
    -m adam_sync/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.{en,de}.yml \
    --disp-freq 10 --after-batches 100 --save-freq 60 \
    --log adam_sync.log --devices 0 1 --sync-sgd

test -e adam_sync/model.npz
test -e adam_sync/model.npz.optimizer.npz
test -e adam_sync.log

$MRT_TOOLS/extract-costs.sh < adam_sync.log > adam_sync.costs.out
$MRT_TOOLS/diff-floats.py adam_sync.costs.out adam_sync.costs.expected -p 3.00 -n 2 > adam_sync.costs.diff

python $MRT_MARIAN/scripts/contrib/model_info.py -m adam_sync/model.npz.optimizer.npz > adam_sync.keys.out
diff adam_sync.keys.out adam_sync.keys.expected > adam_sync.keys.diff

python $MRT_MARIAN/scripts/contrib/model_info.py -m adam_sync/model.npz.optimizer.npz -k mt_ > adam_sync.mt.out
$MRT_TOOLS/diff-floats.py -p 0.0001  adam_sync.mt.out adam_sync.mt.expected > adam_sync.mt.diff
python $MRT_MARIAN/scripts/contrib/model_info.py -m adam_sync/model.npz.optimizer.npz -k vt_ > adam_sync.vt.out
$MRT_TOOLS/diff-floats.py -p 0.0000009 adam_sync.vt.out adam_sync.vt.expected > adam_sync.vt.diff

# Exit with success code
exit 0
