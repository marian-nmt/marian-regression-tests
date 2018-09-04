#!/bin/bash

# Exit on error
set -e

# Remove any files, etc.
clean_up() {
    rm -f train.log
}
trap clean_up EXIT

# Skip if no CUDNN found
if [ ! $MRT_MARIAN_USE_CUDNN ]; then
    exit 100
fi

# Test code goes here
$MRT_MARIAN/build/mnist_example --type mnist-lenet\
    --after-epochs 10 --mini-batch 200 --valid-freq 600 \
    --train-sets train-images-idx3-ubyte train-labels-idx1-ubyte \
    --valid-sets t10k-images-idx3-ubyte t10k-labels-idx1-ubyte \
    --seed 12345 \
    --log train.log

cat train.log | grep '\[valid\]' | sed 's/.*\[valid\] //' > lenet.out

# It seems it's not possible to set a fixed seed and disable the randomness in
# Marian's convnets. It's probably a bug! As a workaround, we check if accuracy
# is higher than a treshold.
# diff -q lenet.out lenet.expected
(( $(grep -c '0\.97' lenet.out) > 1 ))

# Exit with success code
exit 0
