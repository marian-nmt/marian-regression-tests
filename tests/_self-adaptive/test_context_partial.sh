#!/bin/bash

# Exit on error
set -e

# Test code goes here
rm -f contextpart.log

# Run Marian
$MRT_MARIAN/marian-adaptive \
  -m $MRT_MODELS/wmt16_systems/en-de/model.npz \
  -v $MRT_MODELS/wmt16_systems/en-de/vocab.en.json -v $MRT_MODELS/wmt16_systems/en-de/vocab.de.json \
  --dim-vocabs 85000 85000 --dim-emb 500 --after-epochs 1 \
  -t ubuntu.contextpart.src ubuntu.contextpart.ref --log contextpart.log < ubuntu.src > contextpart.out

# Check outputs
$MRT_TOOLS/diff.sh contextpart.out contextpart.expected > contextpart.diff

# Check costs
cat contextpart.log | $MRT_TOOLS/extract-costs.sh > contextpart.costs.out
$MRT_TOOLS/diff-nums.py -p 0.01 contextpart.costs.out contextpart.costs.expected -o contextpart.costs.diff

# Exit with success code
exit 0
