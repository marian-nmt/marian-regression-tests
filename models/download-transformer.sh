#!/bin/bash

# Download EN-DE Transformer model from marian-examples/transformer
wget -nv -nc -r -e robots=off -nH -np -R index.html* --cut-dirs=3 \
    http://data.statmt.org/romang/marian-regression-tests/models/transformer/
