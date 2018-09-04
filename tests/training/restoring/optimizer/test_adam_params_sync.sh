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
    -m adam_sync/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 --save-freq 60 \
    --log adam_sync.log --devices 0 1 --sync-sgd

test -e adam_sync/model.npz
test -e adam_sync/model.npz.optimizer.npz
test -e adam_sync.log

$MRT_TOOLS/extract-costs.sh < adam_sync.log > adam_sync.costs.out
$MRT_TOOLS/diff-floats.py $(pwd)/adam_sync.costs.out $(pwd)/adam_sync.costs.expected -p 3.00 -n 2 | tee $(pwd)/adam_sync.costs.diff | head

python $MRT_MARIAN/scripts/contrib/model_info.py -m adam_sync/model.npz.optimizer.npz > adam_sync.keys.out
diff $(pwd)/adam_sync.keys.out $(pwd)/adam.keys.expected | tee $(pwd)/adam_sync.keys.diff | head

python $MRT_MARIAN/scripts/contrib/model_info.py -m adam_sync/model.npz.optimizer.npz -k "adam_mt" > adam_sync.mt.out
python $MRT_MARIAN/scripts/contrib/model_info.py -m adam_sync/model.npz.optimizer.npz -k "adam_vt" > adam_sync.vt.out

$MRT_TOOLS/diff-floats.py --numpy -p 0.001  $(pwd)/adam_sync.mt.out $(pwd)/adam_sync.mt.expected | tee $(pwd)/adam_sync.mt.diff | head
$MRT_TOOLS/diff-floats.py --numpy -p 0.0001 $(pwd)/adam_sync.vt.out $(pwd)/adam_sync.vt.expected | tee $(pwd)/adam_sync.vt.diff | head

# Exit with success code
exit 0
