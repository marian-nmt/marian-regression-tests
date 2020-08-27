#!/bin/bash

# If you want to add new data files to our Azure storage, open an issue at
# https://github.com/marian-nmt/marian-regression-tests

URL=https://romang.blob.core.windows.net/mariandev/regression-tests/data

# Each tarball is a .tar.gz file that contains a single directory of the same
# name as the tarball
DATA_TARBALLS=(
  europarl.de-en
)

for name in ${DATA_TARBALLS[@]}; do
    file=$name.tar.gz

    echo Downloading checksum for $file ...
    wget -nv -O- $URL/$file.md5 > $name.md5.newest

    # Do not download if the checksum files are identical, i.e. the archive has
    # not been updated since it was downloaded last time
    if test -s $name.md5 && $(cmp --silent $name.md5 $name.md5.newest); then
        echo File $file does not need to be updated
    else
        echo Downloading $file ...
        wget -nv $URL/$file
        # Extract the archive
        tar zxf $file
        # Remove archive to save disk space
        rm -f $file
    fi
    mv $name.md5.newest $name.md5
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
