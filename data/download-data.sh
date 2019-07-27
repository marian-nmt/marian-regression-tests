#!/bin/bash

URL=http://data.statmt.org/romang/marian-regression-tests/data

MODEL_FILES=(
  europarl.de-en/corpus.bpe.de.gz
  europarl.de-en/corpus.bpe.en.gz
)

for file in ${MODEL_FILES[@]}; do
    echo Downloading $file ...
    mkdir -p $(dirname $file)

    if [[ $file = *.gz ]]; then
        target="${file%.*}"

        if [ ! -s $target ]; then
            wget -nv -O- $URL/$file | gzip -dc > $target
        fi
    fi
done

# Get de-BPEed training data
test -s europarl.de-en/corpus.de.gz || pigz -dc europarl.de-en/corpus.bpe.de.gz | sed 's/@@ //g' | pigz > europarl.de-en/corpus.de.gz
test -s europarl.de-en/corpus.en.gz || pigz -dc europarl.de-en/corpus.bpe.en.gz | sed 's/@@ //g' | pigz > europarl.de-en/corpus.en.gz
