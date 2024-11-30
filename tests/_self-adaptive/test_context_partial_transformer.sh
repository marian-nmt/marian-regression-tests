#!/bin/bash

# Exit on error
set -e

# Test code goes here
rm -f contextpart.log

# Run Marian
$MRT_MARIAN/marian-adaptive \
  -m $MRT_MODELS/transformer/model.npz \
  -v $MRT_MODELS/transformer/vocab.ende.yml -v $MRT_MODELS/transformer/vocab.ende.yml \
  --after-epochs 1 \
  -t ubuntu.contextpart.src ubuntu.contextpart.ref --log contextpart.transformer.log < ubuntu.src > contextpart.transformer.out

# Check outputs
$MRT_TOOLS/diff.sh contextpart.out contextpart.expected > contextpart.transformer.diff

# Check costs
cat contextpart.log | $MRT_TOOLS/extract-costs.sh > contextpart.costs.transformer.out
$MRT_TOOLS/diff-nums.py -p 0.01 contextpart.costs.out contextpart.costs.expected -o contextpart.costs.transformer.diff

# Exit with success code
exit 0
