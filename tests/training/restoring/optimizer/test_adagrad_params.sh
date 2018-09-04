#!/bin/bash -x

# Exit on error
set -eo pipefail

# Test code goes here
rm -rf adagrad adagrad*.log
mkdir -p adagrad

$MRT_MARIAN/build/marian \
    --no-shuffle --seed 7777 --maxi-batch 1 --maxi-batch-sort none --dim-emb 128 --dim-rnn 256 \
    -m adagrad/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 10 --after-batches 100 --save-freq 60 -o adagrad\
    --log adagrad.log

test -e adagrad/model.npz
test -e adagrad/model.npz.optimizer.npz
test -e adagrad.log

$MRT_TOOLS/extract-costs.sh < adagrad.log > adagrad.costs.out
$MRT_TOOLS/diff-floats.py $(pwd)/adagrad.costs.out $(pwd)/adagrad.costs.expected -p 0.2 | tee $(pwd)/adagrad.costs.diff | head

python $MRT_MARIAN/scripts/contrib/model_info.py -m adagrad/model.npz.optimizer.npz > adagrad.keys.out
diff $(pwd)/adagrad.keys.out $(pwd)/adagrad.keys.expected | tee $(pwd)/adagrad.keys.diff | head

python $MRT_MARIAN/scripts/contrib/model_info.py -m adagrad/model.npz.optimizer.npz -k "adagrad_gt" > adagrad.gt.out
$MRT_TOOLS/diff-floats.py --numpy -p 0.0001  $(pwd)/adagrad.gt.out $(pwd)/adagrad.gt.expected | tee $(pwd)/adagrad.gt.diff | head

# Exit with success code
exit 0
