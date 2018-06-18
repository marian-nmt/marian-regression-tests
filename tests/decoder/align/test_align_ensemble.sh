#!/bin/bash

# Exit on error
set -e

# Test code goes here
$MRT_MARIAN/build/marian-decoder -m $MRT_MODELS/wmt18/entr/model.rnn.{A,B}.npz -v $MRT_MODELS/wmt18/entr/vocab.{yml,yml} \
    --mini-batch 32 -b 5 --alignment < dev2016.in > ensemble.out
diff ensemble.out ensemble.expected > ensemble.diff

# Exit with success code
exit 0
