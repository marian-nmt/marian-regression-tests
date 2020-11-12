#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf adam adam.log
mkdir -p adam

$MRT_MARIAN/marian \
    --no-shuffle --seed 7777 --maxi-batch 1 --maxi-batch-sort none --dim-emb 128 --dim-rnn 256 \
    -m adam/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 --save-freq 60 --cost-type ce-mean \
    --log adam.log

test -e adam/model.npz
test -e adam/model.npz.optimizer.npz
test -e adam.log

$MRT_TOOLS/extract-costs.sh < adam.log > adam.costs.out
$MRT_TOOLS/diff-nums.py adam.costs.out adam.costs.expected -p 0.2 -o adam.costs.diff

python3 $MRT_MARIAN/../scripts/contrib/model_info.py -m adam/model.npz.optimizer.npz > adam.keys.out
$MRT_TOOLS/diff.sh adam.keys.out adam.keys.expected > adam.keys.diff

python3 $MRT_MARIAN/../scripts/contrib/model_info.py -m adam/model.npz.optimizer.npz -k "adam_mt" > adam.mt.out
$MRT_TOOLS/diff-nums.py --numpy -p 0.0001  adam.mt.out adam.mt.expected -o adam.mt.diff
python3 $MRT_MARIAN/../scripts/contrib/model_info.py -m adam/model.npz.optimizer.npz -k "adam_vt" > adam.vt.out
$MRT_TOOLS/diff-nums.py --numpy -p 0.0001 adam.vt.out adam.vt.expected -o adam.vt.diff

# Exit with success code
exit 0
