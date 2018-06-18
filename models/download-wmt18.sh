#!/bin/bash

# Download WMT18 Turkish models
mkdir -p wmt18/entr
cd wmt18/entr

wget -nc -nv http://data.statmt.org/romang/marian-regression-tests/models/wmt18/entr/model.rnn.A.npz
wget -nc -nv http://data.statmt.org/romang/marian-regression-tests/models/wmt18/entr/model.rnn.B.npz
wget -nc -nv http://data.statmt.org/romang/marian-regression-tests/models/wmt18/entr/vocab.yml
wget -nc -nv http://data.statmt.org/romang/marian-regression-tests/models/wmt18/entr/dev2016.bpe.en

cd -
