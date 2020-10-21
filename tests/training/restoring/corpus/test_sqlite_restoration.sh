#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf sqlite sqlite*.log
mkdir -p sqlite

test -e vocab.de.yml
test -e vocab.en.yml

extra_opts="--seed 3333 --maxi-batch 1 --maxi-batch-sort none --mini-batch 32 --optimizer sgd --dim-emb 128 --dim-rnn 256 --disp-freq 4"
# Added because default options has changes
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"

$MRT_MARIAN/marian \
    -m sqlite/model_full.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 75 --sqlite sqlite/dbfull.sqlite3 $extra_opts \
    --log sqlite.log

test -e sqlite/model_full.npz
test -e sqlite.log

cat sqlite.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > sqlite.expected

$MRT_MARIAN/marian \
    -m sqlite/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 50 --sqlite sqlite/db.sqlite3 $extra_opts \
    --log sqlite_1.log

test -e sqlite/model.npz
test -e sqlite_1.log

cat sqlite_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > sqlite_1.out
cp sqlite/model.npz.yml sqlite/model.npz.1.yml

$MRT_MARIAN/marian \
    -m sqlite/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 75 --sqlite sqlite/db.sqlite3 $extra_opts \
    --log sqlite_2.log

test -e sqlite/model.npz
test -e sqlite_2.log

cat sqlite_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > sqlite_2.out
cat sqlite_1.out sqlite_2.out > sqlite.out

$MRT_TOOLS/diff-nums.py sqlite.out sqlite.expected -p 0.1 -o sqlite.diff

# Exit with success code
exit 0
