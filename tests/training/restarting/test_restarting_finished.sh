#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf finish finish_?.log
mkdir -p finish


$MRT_MARIAN/marian \
    -m finish/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --after-batches 5 --log finish_1.log

test -e finish/model.npz
test -e finish/model.npz.yml
test -e finish_1.log

grep -q "Training finished" finish_1.log

$MRT_MARIAN/marian -c finish/model.npz.yml --log finish_2.log

grep -q "Loading model" finish_2.log
grep -q "Training finished" finish_2.log

# Exit with success code
exit 0
