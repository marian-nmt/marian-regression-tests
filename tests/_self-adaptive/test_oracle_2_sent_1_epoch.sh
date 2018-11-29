#!/bin/bash

# Exit on error
set -e

# Test code goes here
rm -f oracle_2s1e.log

#$MRT_MARIAN/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml < ubuntu.in > trans.out
#diff trans.out trans.expected > trans.diff
#$MRT_TOOLS/moses-scripts/scripts/generic/multi-bleu.perl -lc ubuntu.ref < trans.out > trans.bleu
#diff trans.bleu trans.bleu.expected > trans.bleu.diff


# Run Marian
$MRT_MARIAN/marian-adaptive \
  -m $MRT_MODELS/wmt16_systems/en-de/model.npz \
  -v $MRT_MODELS/wmt16_systems/en-de/vocab.en.json -v $MRT_MODELS/wmt16_systems/en-de/vocab.de.json \
  --dim-vocabs 85000 85000 --dim-emb 500 --after-epochs 1 \
  -t ubuntu.oracle_2s1e.src ubuntu.oracle_2s1e.ref --log oracle_2s1e.log < ubuntu.src > oracle_2s1e.out

# Check outputs
$MRT_TOOLS/diff.sh oracle_2s1e.out oracle.expected > oracle_2s1e.diff

# Check BLEU
$MRT_TOOLS/moses-scripts/scripts/generic/multi-bleu.perl -lc ubuntu.ref < oracle_2s1e.out > oracle_2s1e.bleu
$MRT_TOOLS/diff.sh oracle_2s1e.bleu oracle.bleu.expected > oracle_2s1e.bleu.diff

# Check costs
cat oracle_2s1e.log | grep 'Ep\. ' | $MRT_TOOLS/extract-costs.sh > costs_2s1e.out
$MRT_TOOLS/diff-nums.py -p 0.01 costs_2s1e.out costs.expected -o costs_2s1e.diff

# Exit with success code
exit 0
