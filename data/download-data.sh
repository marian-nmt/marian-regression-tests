#!/bin/bash

# If you want to add new data files to our Azure storage, open an issue at
# https://github.com/marian-nmt/marian-regression-tests

HF_REPO=marian-nmt/marian-regression-tests
which huggingface-cli > /dev/null || {
    echo "huggingface-cli is not found in PATH. Please install it (pip install huggingface_hub) and try again."
    exit 1
}
echo "huggingface-cli is found. Proceeding with the downloads from $HF_REPO"

hf-get(){
    huggingface-cli download --repo-type dataset $HF_REPO $@
}
echo "Downloading from: $URL"

# Each tarball is a .tar.gz file that contains a single directory of the same
# name as the tarball
DATA_TARBALLS=(
  europarl.de-en
  exdb_mnist
)


for name in ${DATA_TARBALLS[@]}; do
    file=$name.tar.gz
    echo Downloading checksum for $file ...

    # hf cli doesnt allow specifying the output file name, it downloads under a directory
    # and also, it repeats dir structure of remote repo in the local one
    hf-get data/$name.md5 --force-download --quiet --local-dir .hub/


    # Do not download if the checksum files are identical, i.e. the archive has
    # not been updated since it was downloaded last time
    if test -s $name.md5 && $(cmp --silent $name.md5 .hub/data/$name.md5); then
        echo File $file does not need to be updated
    else
        echo Downloading $file ...
        hf-get data/$file --force-download --local-dir .hub/
        # Extract the archive
        tar zxf .hub/data/$file
        # Remove archive to save disk space
        rm -f .hub/data/$file
    fi
    mv .hub/data/$name.md5 $name.md5
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
