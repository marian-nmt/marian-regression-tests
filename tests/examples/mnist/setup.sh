#!/bin/bash

# Exit on error
set -e

# Setup code goes here
test -e $MRT_MARIAN/mnist_example

(( $(ls -1 *-ubyte 2>/dev/null | wc -l) == 4 )) && exit 0

wget -nc http://yann.lecun.com/exdb/mnist/train-images-idx3-ubyte.gz
wget -nc http://yann.lecun.com/exdb/mnist/train-labels-idx1-ubyte.gz
wget -nc http://yann.lecun.com/exdb/mnist/t10k-images-idx3-ubyte.gz
wget -nc http://yann.lecun.com/exdb/mnist/t10k-labels-idx1-ubyte.gz

gzip -d *-ubyte.gz

# Exit with success code
exit 0
