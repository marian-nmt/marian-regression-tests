#!/bin/bash

# Exit on error
set -e

# Setup code goes here
test -e $MRT_MARIAN/mnist_example

test -e $MRT_DATA/exdb_mnist/train-images-idx3-ubyte
test -e $MRT_DATA/exdb_mnist/train-labels-idx1-ubyte
test -e $MRT_DATA/exdb_mnist/t10k-images-idx3-ubyte
test -e $MRT_DATA/exdb_mnist/t10k-labels-idx1-ubyte

test -e *-ubyte || cp $MRT_DATA/exdb_mnist/*-ubyte .

# Exit with success code
exit 0
