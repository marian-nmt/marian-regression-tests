#!/bin/bash

# Download a small DE-EN RNN-based model trained with SentencePiece
wget -nv -nc -r -e robots=off -nH -np -R index.html* --cut-dirs=3 \
    http://data.statmt.org/romang/marian-regression-tests/models/rnn-spm
