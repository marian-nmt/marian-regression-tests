#!/bin/bash

root="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
moses_scripts=$root/../../tools/moses-scripts
subword_nmt=$root/../../tools/subword-nmt

model_dir=$root/en-de

$moses_scripts/scripts/tokenizer/normalize-punctuation.perl -l en \
    | $moses_scripts/scripts/tokenizer/tokenizer.perl -l en -penn -threads 16 \
    | $moses_scripts/scripts/recaser/truecase.perl -model $model_dir/truecase-model.en \
    | $subword_nmt/apply_bpe.py -c $model_dir/ende.bpe
