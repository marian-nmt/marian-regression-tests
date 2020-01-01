#!/bin/bash

cat $1 | sacrebleu --tokenize none -b dev.bpe.de
