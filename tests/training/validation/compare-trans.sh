#!/bin/bash

cat $2 | python3 $1/sacrebleu/sacrebleu.py --tokenize none -b dev.bpe.de
