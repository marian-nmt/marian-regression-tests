#!/bin/bash

# If you want to add new data files to our Azure storage, open an issue at
# https://github.com/marian-nmt/marian-regression-tests

URL=https://romang.blob.core.windows.net/mariandev/regression-tests/data

DATA_TARBALLS=(
  europarl.de-en.tar.gz
)

for tar_file in ${DATA_TARBALLS[@]}; do
    echo Downloading $tar_file ...
    # Download
    test -s $tar_file || wget -nv -O- $URL/$tar_file > $tar_file
    # Uncompress
    tar zxf $tar_file
done

DATA_FILES=(
  europarl.de-en/corpus.bpe.de.gz
  europarl.de-en/corpus.bpe.en.gz
)

for file in ${DATA_FILES[@]}; do
    test -s $file || exit 1
    # Uncompress if needed
    target="${file%.*}"
    test -s $target || gzip -dc $file > $target
done

# Get de-BPEed small training data
test -s europarl.de-en/corpus.small.de.gz || head -n 100000 europarl.de-en/corpus.bpe.de | sed 's/@@ //g' | gzip > europarl.de-en/corpus.small.de.gz
test -s europarl.de-en/corpus.small.en.gz || head -n 100000 europarl.de-en/corpus.bpe.en | sed 's/@@ //g' | gzip > europarl.de-en/corpus.small.en.gz
