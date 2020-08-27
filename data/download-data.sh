#!/bin/bash

# If you want to add new data files to our Azure storage, open an issue at
# https://github.com/marian-nmt/marian-regression-tests

URL=https://romang.blob.core.windows.net/mariandev/regression-tests/data

DATA_TARBALLS=(
  europarl.de-en.tar.gz
)

for file in ${DATA_TARBALLS[@]}; do
    echo Downloading checksum for $file ...
    wget -nv -O- $URL/$file.md5 > $file.md5.newest

    # Do not download if the checksum files are identical, i.e. the archive has
    # not been updated since it was downloaded last time
    if test -s $file.md5 && $(cmp --silent $file.md5 $file.md5.newest); then
        echo File $file does not need to be updated
        continue;
    else
        echo Downloading $file ...
        wget -nv $URL/$file
        # Extract the archive
        tar zxf $file
        # Remove archive to save disk space
        rm -f $file
    fi
    mv $file.md5.newest $file.md5
done

DATA_FILES=(
  europarl.de-en/corpus.bpe.de.gz
  europarl.de-en/corpus.bpe.en.gz
)

for file in ${DATA_FILES[@]}; do
    echo Extracting $file ...
    test -s $file || exit 1
    # Uncompress if needed
    target="${file%.*}"
    test -s $target || gzip -dc $file > $target
done

# Get de-BPEed small training data
test -s europarl.de-en/corpus.small.de.gz || head -n 100000 europarl.de-en/corpus.bpe.de | sed 's/@@ //g' | gzip > europarl.de-en/corpus.small.de.gz
test -s europarl.de-en/corpus.small.en.gz || head -n 100000 europarl.de-en/corpus.bpe.en | sed 's/@@ //g' | gzip > europarl.de-en/corpus.small.en.gz
