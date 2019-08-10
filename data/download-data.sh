#!/bin/bash

URL=http://data.statmt.org/romang/marian-regression-tests/data

MODEL_FILES=(
  europarl.de-en/corpus.bpe.de.gz
  europarl.de-en/corpus.bpe.en.gz
)

for file in ${MODEL_FILES[@]}; do
    echo Downloading $file ...
    mkdir -p $(dirname $file)

    # Download the file
    test -s $file || wget -nv -O- $URL/$file > $file

    # Uncompress if needed
    if [[ $file = *.gz ]]; then
        target="${file%.*}"
        test -s $target || gzip -dc $file > $target
    fi
done

# Get de-BPEed small training data
test -s europarl.de-en/corpus.small.de.gz || head -n 100000 europarl.de-en/corpus.bpe.de | sed 's/@@ //g' | gzip > europarl.de-en/corpus.small.de.gz
test -s europarl.de-en/corpus.small.en.gz || head -n 100000 europarl.de-en/corpus.bpe.en | sed 's/@@ //g' | gzip > europarl.de-en/corpus.small.en.gz
