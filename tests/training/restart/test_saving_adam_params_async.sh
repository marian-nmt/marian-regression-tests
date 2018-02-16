#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf adam_async adam_async*.log
mkdir -p adam_async

if (( $MRT_NUM_DEVICES < 2 )); then
    echo "Too few devices available"
    exit 100
fi

$MRT_MARIAN/build/marian \
    --no-shuffle --seed 7777 --maxi-batch 1 --maxi-batch-sort none --mini-batch 32 --dim-emb 128 --dim-rnn 256 \
    -m adam_async/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.{en,de}.yml \
    --disp-freq 10 --after-batches 100 --save-freq 60 \
    --log adam_async.log --devices 0 1

test -e adam_async/model.npz
test -e adam_async/model.npz.optimizer.npz
test -e adam_async.log

$MRT_TOOLS/extract-costs.sh < adam_async.log > adam_async.costs.out
$MRT_TOOLS/diff-floats.py adam_async.costs.out adam_async.costs.expected -p 3.00 -n 2 > adam_async.costs.diff

python $MRT_MARIAN/scripts/contrib/model_info.py -m adam_async/model.npz.optimizer.npz > adam_async.keys.out
diff adam_async.keys.out adam_async.keys.expected > adam_async.keys.diff

python $MRT_MARIAN/scripts/contrib/model_info.py -m adam_async/model.npz.optimizer.npz -k mt_ > adam_async.mt.out
$MRT_TOOLS/diff-floats.py -p 0.0001  adam_async.mt.out adam_async.mt.expected > adam_async.mt.diff
python $MRT_MARIAN/scripts/contrib/model_info.py -m adam_async/model.npz.optimizer.npz -k vt_ > adam_async.vt.out
$MRT_TOOLS/diff-floats.py -p 0.0000009 adam_async.vt.out adam_async.vt.expected > adam_async.vt.diff

# Exit with success code
exit 0
