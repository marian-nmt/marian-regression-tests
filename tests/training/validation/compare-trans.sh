#!/bin/bash

cat $2 | $1/sacrebleu/sacrebleu.py --tokenize none -b dev.bpe.de
