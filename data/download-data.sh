#!/bin/bash

URL=http://data.statmt.org/romang/marian-regression-tests/data

MODEL_FILES=(
  europarl.de-en/corpus.bpe.de.gz
  europarl.de-en/corpus.bpe.en.gz
)

for file in ${MODEL_FILES[@]}; do
    echo $file
    mkdir -p $(dirname $file)

    if [[ $file = *.gz ]]; then
        wget -qO- $URL/$file | gzip -dc > "${file%.*}"
    fi

done
