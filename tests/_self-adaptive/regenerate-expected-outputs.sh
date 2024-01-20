#!/bin/bash
set -euo pipefail

MRT_MODELS=../../models
MRT_TOOLS=../../tools

MODELS=$MRT_MODELS/wmt16_systems/en-de

echo "### Generating files for the oracle tests"
./gen-costs.py \
    -t ubuntu.oracle_2s1e.{src,ref} \
    -m $MODELS/model.npz \
    --type amun \
    --dim-vocabs 85000 85000 \
    --dim-emb 500 \
    -v $MODELS/vocab.{en,de}.json \
    -e 1 \
    --marian-dir ~/prog/cpp/marian-adaptive/build/ \
    -i ubuntu.src \
    --output-costs costs.expected \
    --output-transl oracle.expected

# Generate BLEU
$MRT_TOOLS/moses-scripts/scripts/generic/multi-bleu.perl -lc ubuntu.ref < oracle.expected > oracle.bleu.expected

echo -e "\n\n### Generating files for the partial context tests"
./gen-costs.py \
    -t ubuntu.contextpart.{src,ref} \
    -m $MODELS/model.npz \
    --type amun \
    --dim-vocabs 85000 85000 \
    --dim-emb 500 \
    -v $MODELS/vocab.{en,de}.json \
    -e 1 \
    --marian-dir ~/prog/cpp/marian-adaptive/build/ \
    -i ubuntu.src \
    --output-costs contextpart.costs.expected \
    --output-transl contextpart.expected


echo -e "\n\n### Generating files for the no context tests"
./gen-costs.py \
    -t ubuntu.nocontext.{src,ref} \
    -m $MODELS/model.npz \
    --type amun \
    --dim-vocabs 85000 85000 \
    --dim-emb 500 \
    -v $MODELS/vocab.{en,de}.json \
    -e 1 \
    --marian-dir ~/prog/cpp/marian-adaptive/build/ \
    -i ubuntu.src \
    --output-transl nocontext.expected


echo -e "\n\n### Generating files for the transformer partial context tests"
./gen-costs.py \
    -t ubuntu.contextpart.{src,ref} \
    -m $MRT_MODELS/transformer/model.npz \
    --type transformer \
    -v $MRT_MODELS/transformer/vocab.ende.yml{,} \
    -e 1 \
    --marian-dir ~/prog/cpp/marian-adaptive/build/ \
    -i ubuntu.src \
    --output-costs transformer.contextpart.costs.expected \
    --output-transl transformer.contextpart.expected
