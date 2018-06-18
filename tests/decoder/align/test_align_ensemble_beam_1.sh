#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/build/marian-decoder -m $MRT_MODELS/wmt18/entr/model.rnn.{A,B}.npz -v $MRT_MODELS/wmt18/entr/vocab.{yml,yml} \
    --mini-batch 1 -b 1 --alignment < dev2016.in > ensemble.b1.out
diff ensemble.b1.out ensemble.b1.expected > ensemble.b1.diff

# Exit with success code
exit 0
