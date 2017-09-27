#!/bin/bash -v

# This sample script preprocesses a sample corpus, including tokenization,
# truecasing, and subword segmentation.
# For application to a different language pair, change source and target
# prefix, optionally the number of BPE operations, and the file names
# (currently, data/corpus and data/newsdev2016 are being processed)

# suffix of source language files
SRC=de

# suffix of target language files
TRG=en

# number of merge operations. Network vocabulary should be slightly larger (to include characters),
# or smaller if the operations are learned on the joint vocabulary
bpe_operations=30000

# path to moses decoder: https://github.com/moses-smt/mosesdecoder
mosesdecoder=$(realpath ../tools/moses-scripts)

# path to subword segmentation scripts: https://github.com/rsennrich/subword-nmt
subword_nmt=$(realpath ../tools/subword-nmt)

# stop if corpus is ready
if [ -s corpus.bpe.$SRC ]; then
    exit 0
fi

# download europarl data
wget -nc --directory-prefix europarl.$SRC-$TRG http://www.statmt.org/europarl/v7/$SRC-$TRG.tgz

cd europarl.$SRC-$TRG
tar -xf $SRC-$TRG.tgz

mv europarl-v7.$SRC-$TRG.$TRG corpus.$TRG
mv europarl-v7.$SRC-$TRG.$SRC corpus.$SRC

# tokenize
for prefix in corpus; do
    cat $prefix.$SRC \
        | $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl -l $SRC \
        | $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $SRC > $prefix.tok.raw.$SRC

    cat $prefix.$TRG \
        | $mosesdecoder/scripts/tokenizer/normalize-punctuation.perl -l $TRG \
        | $mosesdecoder/scripts/tokenizer/tokenizer.perl -a -l $TRG > $prefix.tok.raw.$TRG
done

# clean empty and long sentences, and sentences with high source-target ratio (training corpus only)
$mosesdecoder/scripts/training/clean-corpus-n.perl corpus.tok.raw $SRC $TRG corpus.tok 1 80

# train truecaser
$mosesdecoder/scripts/recaser/train-truecaser.perl -corpus corpus.tok.$SRC -model truecase-model.$SRC
$mosesdecoder/scripts/recaser/train-truecaser.perl -corpus corpus.tok.$TRG -model truecase-model.$TRG

# apply truecaser
for prefix in corpus; do
    $mosesdecoder/scripts/recaser/truecase.perl -model truecase-model.$SRC < $prefix.tok.$SRC > $prefix.tc.$SRC
    $mosesdecoder/scripts/recaser/truecase.perl -model truecase-model.$TRG < $prefix.tok.$TRG > $prefix.tc.$TRG
done

# train BPE
cat corpus.tc.$SRC corpus.tc.$TRG | $subword_nmt/learn_bpe.py -s $bpe_operations > $SRC$TRG.bpe

# apply BPE
for prefix in corpus; do
    $subword_nmt/apply_bpe.py -c $SRC$TRG.bpe < $prefix.tc.$SRC > $prefix.bpe.$SRC
    $subword_nmt/apply_bpe.py -c $SRC$TRG.bpe < $prefix.tc.$TRG > $prefix.bpe.$TRG
done

cd ..
