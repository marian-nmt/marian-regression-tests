#!/bin/bash

# Download char-s2s model
mkdir -p char-s2s
cd char-s2s

wget -nc -nv http://data.statmt.org/romang/marian-regression-tests/models/char-s2s/model.npz
wget -nc -nv http://data.statmt.org/romang/marian-regression-tests/models/char-s2s/translate.yml
wget -nc -nv http://data.statmt.org/romang/marian-regression-tests/models/char-s2s/vocab.en.yml
wget -nc -nv http://data.statmt.org/romang/marian-regression-tests/models/char-s2s/vocab.ro.yml

cd -
