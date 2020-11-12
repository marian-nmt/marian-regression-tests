#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf sgd_2e sgd_1st_epoch.log sgd_2nd_epoch.log
mkdir -p sgd_2e

extra_opts="--no-shuffle --seed 1111 --maxi-batch 1 --maxi-batch-sort none --mini-batch 32 --optimizer sgd"
# Added because default options has changes
extra_opts="$extra_opts --cost-type ce-mean --disp-label-counts false"


# Uncomment to prepare the expected output
#$MRT_MARIAN/marian \
    #-m sgd_2e/model_2e.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    #--disp-freq 4 --save-freq 32 --after-epochs 2 -l 0.1 $extra_opts \
    #--log sgd_two_epochs.log

#test -e sgd_2e/model_2e.npz
#test -e sgd_two_epochs.log
#cat sgd_two_epochs.log | $MRT_TOOLS/extract-disp.sh > sgd_2e.expected
#exit 1


$MRT_MARIAN/marian \
    -m sgd_2e/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 4 --save-freq 32 --after-epochs 1 -l 0.1 $extra_opts \
    --log sgd_1st_epoch.log

test -e sgd_2e/model.npz
test -e sgd_1st_epoch.log

cat sgd_1st_epoch.log | $MRT_TOOLS/extract-disp.sh > sgd_1st_epoch.out
cp sgd_2e/model.npz.yml sgd_2e/model.npz.1st_epoch.yml

$MRT_MARIAN/marian \
    -m sgd_2e/model.npz -t $MRT_DATA/train.max50.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 4 --save-freq 32 --after-epochs 2 -l 0.1 $extra_opts \
    --log sgd_2nd_epoch.log

test -e sgd_2e/model.npz
test -e sgd_2nd_epoch.log

cat sgd_2nd_epoch.log | $MRT_TOOLS/extract-disp.sh > sgd_2nd_epoch.out
cat sgd_1st_epoch.out sgd_2nd_epoch.out > sgd_2e.out

$MRT_TOOLS/diff-nums.py sgd_2e.out sgd_2e.expected -p 0.1 -o sgd_2e.diff

# Exit with success code
exit 0
