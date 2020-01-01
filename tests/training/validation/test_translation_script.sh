#!/bin/bash -x

#####################################################################
# SUMMARY: Test validation with a translation script
# AUTHOR: snukky
# TAGS: valid
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf trans trans.log trans_script.temp
mkdir -p trans

$MRT_MARIAN/marian \
    --seed 2222 --no-shuffle --dim-emb 128 --dim-rnn 256 --maxi-batch 1 --mini-batch 16 \
    -m trans/model.npz \
    -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.50k.en.yml vocab.50k.de.yml \
    --dim-vocabs 50000 50000 \
    --disp-freq 30 --valid-freq 60 --after-batches 150 \
    --valid-metrics cross-entropy translation --valid-script-path ./trans_script.sh \
    --valid-sets trans.bpe.en trans.bpe.de \
    --valid-log trans.log

test -e trans/model.npz
test -e trans/model.npz.yml
test -e trans/model.npz.amun.yml

test -e trans.log

grep -q "/tmp/marian.*" trans_script.temp

$MRT_TOOLS/strip-timestamps.sh < trans.log | grep -v "Total translation time" | head -n 4 > trans.out
$MRT_TOOLS/diff-nums.py trans.out trans.expected -p 0.2 -o trans.diff

# Exit with success code
exit 0
