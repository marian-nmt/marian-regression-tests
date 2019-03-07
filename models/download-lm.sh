#!/bin/bash -x

test -e lmgec/lm.npz && exit

mkdir -p lmgec
cd lmgec
wget -nv -nc http://data.statmt.org/romang/gec-naacl18/models.tgz
tar zxvf models.tgz lm.npz tc.model gec.bpe vocab.yml
rm models.tgz
cd ..
