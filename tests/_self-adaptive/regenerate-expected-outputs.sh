#!/bin/bash
set -euo pipefail

MRT_MODELS=../../models
MRT_TOOLS=../../tools

MODELS=$MRT_MODELS/wmt16_systems/en-de

./gen-costs.py \
    -t ubuntu.oracle_2s1e.{src,ref} \
    -m $MODELS/model.npz \
    -v $MODELS/vocab.{en,de}.json \
    -e 1 \
    --marian-dir ~/prog/cpp/marian-adaptive/build/ \
    -i ubuntu.src \
    --output-costs costs.expected \
    --output-transl oracle.expected

# Generate BLEU
$MRT_TOOLS/moses-scripts/scripts/generic/multi-bleu.perl -lc ubuntu.ref < oracle.expected > oracle.bleu.expected



./gen-costs.py \
    -t ubuntu.oracle_2s1e.{src,ref} \
    -m $MODELS/model.npz \
    -v $MODELS/vocab.{en,de}.json \
    -e 1 \
    --marian-dir ~/prog/cpp/marian-adaptive/build/ \
    -i ubuntu.src \
    --output-costs costs.expected \
    --output-transl oracle.expected

# Generate BLEU
$MRT_TOOLS/moses-scripts/scripts/generic/multi-bleu.perl -lc ubuntu.ref < oracle.expected2 > oracle.bleu.expected2
