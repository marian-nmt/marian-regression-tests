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

$MRT_MARIAN/marian \
    --no-shuffle --seed 7777 --maxi-batch 1 --maxi-batch-sort none --mini-batch 32 --dim-emb 128 --dim-rnn 256 \
    -m adam_async/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 --save-freq 60 --cost-type ce-sum --disp-label-counts false \
    --log adam_async.log --devices 0 1

test -e adam_async/model.npz
test -e adam_async/model.npz.optimizer.npz
test -e adam_async.log

# Costs differ significantly between GTX 1080/TITAN Black and TITAN X (Pascal),
# but we rather keep the test with a high error margin (ca. 1/14) than disabling it
$MRT_TOOLS/extract-costs.sh < adam_async.log > adam_async.costs.out
$MRT_TOOLS/diff-nums.py adam_async.costs.out adam_async.costs.expected -p 500.0 -o adam_async.costs.diff

python3 $MRT_MARIAN/../scripts/contrib/model_info.py -m adam_async/model.npz.optimizer.npz > adam_async.keys.out
$MRT_TOOLS/diff.sh adam_async.keys.out adam.keys.expected > adam_async.keys.diff

python3 $MRT_MARIAN/../scripts/contrib/model_info.py -m adam_async/model.npz.optimizer.npz -k "adam_mt" > adam_async.mt.out
python3 $MRT_MARIAN/../scripts/contrib/model_info.py -m adam_async/model.npz.optimizer.npz -k "adam_vt" > adam_async.vt.out

$MRT_TOOLS/diff-nums.py --numpy -a -p 0.02  adam_async.mt.out adam_async.mt.expected -o adam_async.mt.diff
$MRT_TOOLS/diff-nums.py --numpy    -p 0.001 adam_async.vt.out adam_async.vt.expected -o adam_async.vt.diff

# Exit with success code
exit 0
