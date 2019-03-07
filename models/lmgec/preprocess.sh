#!/bin/bash

ROOTDIR=$(realpath ../..)

cat \
    | perl $ROOTDIR/tools/moses-scripts/scripts/recaser/detruecase.perl \
    | perl $ROOTDIR/tools/moses-scripts/scripts/tokenizer/detokenizer.perl -l en \
    | python ./nltk_tok.py \
    | perl $ROOTDIR/tools/moses-scripts/scripts/tokenizer/escape-special-chars.perl \
    | perl $ROOTDIR/tools/moses-scripts/scripts/recaser/truecase.perl --model tc.model \
    | perl $ROOTDIR/tools/subword-nmt/subword_nmt/apply_bpe.py -c gec.bpe
