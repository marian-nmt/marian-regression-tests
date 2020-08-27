#!/bin/bash

# If you want to add new model files to our Azure storage, open an issue at
# https://github.com/marian-nmt/marian-regression-tests

URL=https://romang.blob.core.windows.net/mariandev/regression-tests/models

# Each tarball contains a single directory of the same name as the tarball without .tar.gz
DATA_TARBALLS=(
    wmt16_systems.tar.gz  # A part of En-De WMT16 model from http://data.statmt.org/wmt16_systems/en-de/
    wmt17_systems.tar.gz  # A part of En-De WMT17 model from http://data.statmt.org/wmt17_systems/en-de/
    ape.tar.gz            # A multi-source Transformer model trained on WMT16: APE Shared Task data with SentencePiece
    lmgec.tar.gz          # LM from http://data.statmt.org/romang/gec-naacl18/models.tgz
    rnn-spm.tar.gz        # Small De-En RNN-based model trained with SentencePiece
    transformer.tar.gz    # En-De transformer model from marian-examples/transformer
    wnmt18.tar.gz         # WNMT18 student models
    wngt19.tar.gz         # WNGT19 student models
    student-eten.tar.gz   # Et-En student model from https://github.com/browsermt/students
    #char-s2s.tar.gz       # A character-level RNN model (obsolete)
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
