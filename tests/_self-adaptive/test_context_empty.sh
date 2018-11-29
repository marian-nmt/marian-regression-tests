#!/bin/bash

# Exit on error
set -e

# Test code goes here
rm -f nocontext.log

# Run Marian
$MRT_MARIAN/marian-adaptive \
  -m $MRT_MODELS/wmt16_systems/en-de/model.npz \
  -v $MRT_MODELS/wmt16_systems/en-de/vocab.en.json -v $MRT_MODELS/wmt16_systems/en-de/vocab.de.json \
  --dim-vocabs 85000 85000 --dim-emb 500 --after-epochs 1 \
  -t ubuntu.nocontext.src ubuntu.nocontext.ref --log nocontext.log < ubuntu.src > nocontext.out

# Check outputs
$MRT_TOOLS/diff.sh nocontext.out nocontext.expected > nocontext.diff

# Check if the log file does not contain training logs
grep -q "Ep\." nocontext.log && exit 1

# Exit with success code
exit 0
