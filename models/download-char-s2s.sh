#!/bin/bash

# Download single char-s2s model frmo vali

mkdir -p char-s2s
cd char-s2s
wget -nc -nv http://data.statmt.org/marian/models/char-s2s/model.iter350000.npz
wget -nc -nv http://data.statmt.org/marian/models/char-s2s/translate.yml
wget -nc -nv http://data.statmt.org/marian/models/char-s2s/vocab.en.yml
wget -nc -nv http://data.statmt.org/marian/models/char-s2s/vocab.ro.yml

cd -
