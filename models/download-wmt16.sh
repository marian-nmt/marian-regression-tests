#!/bin/bash

URL=http://data.statmt.org/rsennrich/wmt16_systems
SRC=en
TRG=de

MODEL_FILES=(
  $URL/$SRC-$TRG/model.npz
  $URL/$SRC-$TRG/model.npz.json
  $URL/$SRC-$TRG/vocab.$SRC.json
  $URL/$SRC-$TRG/vocab.$TRG.json
  $URL/$SRC-$TRG/$SRC$TRG.bpe
  $URL/$SRC-$TRG/truecase-model.$SRC
)

mkdir -p wmt16.$SRC-$TRG

for model_file in ${MODEL_FILES[@]}; do
    echo $model_file
    wget -q --no-clobber --directory-prefix wmt16.$SRC-$TRG $model_file
done
