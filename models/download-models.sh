#!/usr/bin/env bash

# Download model tarballs from Marian storage on Azure.
#
# Usage examples:
#   ./download-models.sh            # download all tarbals
#   ./download-models.sh wngt19     # download only wngt19.tar.gz
#
# If you want to add new model files to our Azure storage, open an issue at
# https://github.com/marian-nmt/marian-regression-tests


HF_REPO=marian-nmt/marian-regression-tests
which  huggingface-cli > /dev/null || {
    echo "huggingface-cli is not found in PATH. Please install it (pip install huggingface_hub) and try again."
    exit 1
}

echo "huggingface-cli is found. Proceeding with the downloads from $HF_REPO"

hf-get(){
    huggingface-cli download --repo-type dataset $HF_REPO $@
}

# Each tarball is a .tar.gz file that contains a single directory of the same
# name as the tarball without .tar.gz
MODEL_TARBALLS=(
    wmt16_systems  # A part of En-De WMT16 model from http://data.statmt.org/wmt16_systems/en-de/
    wmt17_systems  # A part of En-De WMT17 model from http://data.statmt.org/wmt17_systems/en-de/
    ape            # A multi-source Transformer model trained on WMT16: APE Shared Task data with SentencePiece
    lmgec          # LM from http://data.statmt.org/romang/gec-naacl18/models.tgz
    rnn-spm        # Small De-En RNN-based model trained with SentencePiece
    transformer    # En-De transformer model from marian-examples/transformer
    wnmt18         # WNMT18 student models
    wngt19         # WNGT19 student models
    student-eten   # Et-En student model from https://github.com/browsermt/students
    factors        # Small En-De model trained with factorized vocabs by Unbabel
    #char-s2s       # A character-level RNN model (obsolete)
)


if [ $# -gt 0 ]; then
    echo The list of parameters is not empty.
    echo Skipping models not in the list: $*
fi

for model in ${MODEL_TARBALLS[@]}; do
    file=$model.tar.gz

    # If an argument list is provided, download only tarballs that are present
    # in the list. Otherwise download all predefined tarballs
    if [ $# -gt 0 ] && [[ "$file" != *"$*"* ]]; then
        echo Skipping $file
        continue;
    fi

    echo Downloading checksum for $file ...
    # hf cli doesnt allow specifying the output file name, it downloads under a directory
    # and also, it repeats dir structure of remote repo in the local one
    hf-get models/$model.md5 --force-download --quiet --local-dir .hub/

    # Do not download if the checksum files are identical, i.e. the archive has
    # not been updated since it was downloaded last time
    if test -s $model.md5 && $(cmp --silent $model.md5 .hub/models/$model.md5); then
        echo File $file does not need to be updated
    else
        echo Downloading $file ...
        # download; note: it will be stored in the models/ directory
        hf-get models/$file --force-download --local-dir .hub/
        # Extract the archive
        tar zxf .hub/models/$file
        # Remove archive to save disk space
        rm -f .hub/models/$file
        # remove old md5 file
    fi
    rm -f $model.md5
    mv .hub/models/$model.md5 $model.md5
done
