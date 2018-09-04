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
    -m adam_async/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 --save-freq 60 \
    --log adam_async.log --devices 0 1

test -e adam_async/model.npz
test -e adam_async/model.npz.optimizer.npz
test -e adam_async.log

$MRT_TOOLS/extract-costs.sh < adam_async.log > adam_async.costs.out
$MRT_TOOLS/diff-floats.py $(pwd)/adam_async.costs.out $(pwd)/adam_async.costs.expected -p 10.00 -n 2 | tee $(pwd)/adam_async.costs.diff | head

python $MRT_MARIAN/scripts/contrib/model_info.py -m adam_async/model.npz.optimizer.npz > adam_async.keys.out
diff $(pwd)/adam_async.keys.out $(pwd)/adam.keys.expected | tee $(pwd)/adam_async.keys.diff | head

python $MRT_MARIAN/scripts/contrib/model_info.py -m adam_async/model.npz.optimizer.npz -k "adam_mt" > adam_async.mt.out
python $MRT_MARIAN/scripts/contrib/model_info.py -m adam_async/model.npz.optimizer.npz -k "adam_vt" > adam_async.vt.out

$MRT_TOOLS/diff-floats.py --numpy -a -p 0.02  $(pwd)/adam_async.mt.out $(pwd)/adam_async.mt.expected | tee $(pwd)/adam_async.mt.diff | head
$MRT_TOOLS/diff-floats.py --numpy    -p 0.001 $(pwd)/adam_async.vt.out $(pwd)/adam_async.vt.expected | tee $(pwd)/adam_async.vt.diff | head

# Exit with success code
exit 0
