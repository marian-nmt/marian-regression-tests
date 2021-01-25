#!/bin/bash -x

# Exit on error
set -e

if (( $MRT_NUM_DEVICES < 2 )); then
    echo "Too few devices available"
    exit 100
fi

# Test code goes here
rm -rf async async_*.log async.*out async.*expected
mkdir -p async

opts="--no-shuffle --seed 777 --mini-batch 1 --maxi-batch 1 --maxi-batch-sort none --dim-rnn 64 --dim-emb 32 --optimizer sgd --learn-rate 0.1 --devices 0 1"
# Added because default options has changes
opts="$opts --cost-type ce-mean --disp-label-counts false"

opt_disp=1
opt_save=8
opt_finish=16

$MRT_MARIAN/marian \
    -m async/model.full.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --after-batches $opt_finish $opts \
    --log async_f.log

test -e async/model.full.npz
test -e async_f.log

cat async_f.log | $MRT_TOOLS/extract-costs.sh > async.unsorted.expected

$MRT_MARIAN/marian \
    -m async/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --after-batches $opt_save $opts \
    --log async_1.log

test -e async/model.npz
test -e async_1.log

cat async_1.log | $MRT_TOOLS/extract-costs.sh > async.unsorted.out


$MRT_MARIAN/marian \
    -m async/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq $opt_disp --after-batches $opt_finish $opts \
    --log async_2.log

test -e async/model.npz
test -e async_2.log

# costs are sorted as the order of each N (N is the number of GPUs) consecutive costs is undeterministic
cat async_2.log | $MRT_TOOLS/extract-costs.sh >> async.unsorted.out

cat async.unsorted.expected | head -n -4 | sort -n > async.expected
cat async.unsorted.out | head -n -4 | sort -n > async.out

# async is undeterministic, so the conditions are weak
$MRT_TOOLS/diff-nums.py -p 1.0 -n 2 async.out async.expected -o async.diff

# Exit with success code
exit 0
