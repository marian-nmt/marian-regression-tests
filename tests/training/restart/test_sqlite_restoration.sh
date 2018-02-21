#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf corpus_sqlite corpus_sqlite*.log
mkdir -p corpus_sqlite

test -e vocab.de.yml
test -e vocab.en.yml

extra_opts="--seed 1111 --maxi-batch 1 --maxi-batch-sort none --mini-batch 32 -o sgd --dim-emb 128 --dim-rnn 256 --disp-freq 4 --restore-corpus"

$MRT_MARIAN/build/marian \
    -m corpus_sqlite/model_full.npz -t train.max50.{en,de} -v vocab.{en,de}.yml \
    --after-batches 70 --sqlite corpus_sqlite/dbfull.sqlite3 $extra_opts \
    --log corpus_sqlite.log

test -e corpus_sqlite/model_full.npz
test -e corpus_sqlite.log

cat corpus_sqlite.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_sqlite.expected

$MRT_MARIAN/build/marian \
    -m corpus_sqlite/model.npz -t train.max50.{en,de} -v vocab.{en,de}.yml \
    --after-batches 40 --sqlite corpus_sqlite/db.sqlite3 $extra_opts \
    --log corpus_sqlite_1.log

test -e corpus_sqlite/model.npz
test -e corpus_sqlite_1.log

cat corpus_sqlite_1.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_sqlite_1.out
cp corpus_sqlite/model.npz.yml corpus_sqlite/model.npz.1.yml

$MRT_MARIAN/build/marian \
    -m corpus_sqlite/model.npz -t train.max50.{en,de} -v vocab.{en,de}.yml \
    --after-batches 70 --sqlite corpus_sqlite/db.sqlite3 $extra_opts \
    --log corpus_sqlite_2.log

test -e corpus_sqlite/model.npz
test -e corpus_sqlite_2.log

cat corpus_sqlite_2.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | sed 's/ : Time.*//' > corpus_sqlite_2.out
cat corpus_sqlite_1.out corpus_sqlite_2.out > corpus_sqlite.out

$MRT_TOOLS/diff-floats.py corpus_sqlite.out corpus_sqlite.expected -p 0.1 > corpus_sqlite.diff

# Exit with success code
exit 0
