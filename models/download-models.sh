#!/bin/bash

# Download model tarballs from Marian storage on Azure.
#
# Usage examples:
#   ./download-models.sh            # download all tarbals
#   ./download-models.sh wngt19     # download only wngt19.tar.gz
#
# If you want to add new model files to our Azure storage, open an issue at
# https://github.com/marian-nmt/marian-regression-tests

URL=https://romang.blob.core.windows.net/mariandev/regression-tests/models
TOKEN="${AZURE_STORAGE_SAS_TOKEN:-}"

# If the SAS token is not provided, switch to to the mirror server
if [ -z $TOKEN ]; then
    URL=http://data.statmt.org/romang/marian-regression-tests/models
fi

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

AZCOPY=true
if ! grep -q "blob\.core\.windows\.net" <<< "$URL"; then
    AZCOPY=false
elif ! command -v azcopy &> /dev/null; then
    echo "Warning: 'azcopy' is not installed in your system. Using wget."
    AZCOPY=false
fi

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
    if $AZCOPY; then
        azcopy copy "$URL/$file.md5?$TOKEN" $model.md5.newest
    else
        wget -nv -O- $URL/$file.md5 > $model.md5.newest
    fi

    # Do not download if the checksum files are identical, i.e. the archive has
    # not been updated since it was downloaded last time
    if test -s $model.md5 && $(cmp --silent $model.md5 $model.md5.newest); then
        echo File $file does not need to be updated
    else
        echo Downloading $file ...
        if $AZCOPY; then
            azcopy copy "$URL/$file?$TOKEN" .
        else
            wget -nv $URL/$file
        fi
        # Extract the archive
        tar zxf $file
        # Remove archive to save disk space
        rm -f $file
    fi
    mv $model.md5.newest $model.md5
done
