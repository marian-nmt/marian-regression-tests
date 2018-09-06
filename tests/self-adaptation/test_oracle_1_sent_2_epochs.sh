#!/bin/bash

# Exit on error
set -e

# Test code goes here
rm -f domain.log

#$MRT_MARIAN/build/marian-decoder -c $MRT_MODELS/wmt16_systems/marian.en-de.yml < ubuntu.in > trans.out
#diff trans.out trans.expected > trans.diff
#$MRT_TOOLS/moses-scripts/scripts/generic/multi-bleu.perl -lc ubuntu.ref < trans.out > trans.bleu
#diff trans.bleu trans.bleu.expected > trans.bleu.diff


# Run multi-domain
$MRT_MARIAN/build/marian-self-adapt \
  -m $MRT_MODELS/wmt16_systems/en-de/model.npz \
  -v $MRT_MODELS/wmt16_systems/en-de/vocab.en.json -v $MRT_MODELS/wmt16_systems/en-de/vocab.de.json \
  --dim-vocabs 85000 85000 --dim-emb 500 \
  -t ubuntu.train.src ubuntu.train.ref --log domain.log < ubuntu.src > domain.out

# Check outputs
diff domain.out domain.expected > domain.diff

# Check BLEU
$MRT_TOOLS/moses-scripts/scripts/generic/multi-bleu.perl -lc ubuntu.ref < domain.out > domain.bleu
diff domain.bleu domain.bleu.expected > domain.bleu.diff

# Check costs
cat domain.log | grep 'Ep\. ' | $MRT_TOOLS/strip-timestamps.sh | sed 's/ : Time.*//' > costs.out
$MRT_TOOLS/diff-floats.py -p 0.01 costs.out costs.expected > costs.diff

# Exit with success code
exit 0
