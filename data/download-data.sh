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

# Get de-BPEed small training data
test -s europarl.de-en/corpus.small.de.gz || pigz -dc europarl.de-en/corpus.bpe.de.gz | head -n 100000 | sed 's/@@ //g' | pigz > europarl.de-en/corpus.small.de.gz
test -s europarl.de-en/corpus.small.en.gz || pigz -dc europarl.de-en/corpus.bpe.en.gz | head -n 100000 | sed 's/@@ //g' | pigz > europarl.de-en/corpus.small.en.gz
