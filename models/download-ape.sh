#!/bin/bash

# Download the multi-source Transformer model trained on WMT16: APE Shared Task data with SentencePiece
wget -nv -nc -r -nH -np -R "index.html*" -e robots=off --cut-dirs=3 \
    http://data.statmt.org/romang/marian-regression-tests/models/ape
