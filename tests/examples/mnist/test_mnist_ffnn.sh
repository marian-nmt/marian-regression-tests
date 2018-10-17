#!/bin/bash

# Exit on error
set -e

# Remove any files, etc.
clean_up() {
    rm -f train.log
}
trap clean_up EXIT

# Test code goes here
$MRT_MARIAN/build/mnist_example \
    --after-epochs 20 --mini-batch 200 --valid-freq 600 --maxi-batch 1 \
    --train-sets train-images-idx3-ubyte train-labels-idx1-ubyte \
    --valid-sets t10k-images-idx3-ubyte t10k-labels-idx1-ubyte \
    --seed 12345 \
    --log train.log

cat train.log | grep '\[valid\]' | sed 's/.*\[valid\] //' > ffnn.out
$MRT_TOOLS/diff-floats.py ffnn.out ffnn.expected -p 0.003 > ffnn.diff

# Exit with success code
exit 0
