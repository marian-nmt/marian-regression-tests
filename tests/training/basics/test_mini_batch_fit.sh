#!/bin/bash -x

#####################################################################
# SUMMARY: Train with --mini-batch-fit
# AUTHOR: snukky
# TAGS: mini-batch-fit
#####################################################################

# Exit on error
set -e

# Check if 'bc' is installed
type bc || exit 100

# Test code goes here
rm -rf batch_fit batch_fit.log
mkdir -p batch_fit

$MRT_MARIAN/marian \
    --no-shuffle --seed 1111 --dim-emb 128 --dim-rnn 256 \
    -m batch_fit/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 20 --after-batches 100 \
    --log batch_fit.log \
    --mini-batch-fit -w 3500

test -e batch_fit/model.npz
test -e batch_fit/model.npz.yml
test -e batch_fit/model.npz.amun.yml

test -e batch_fit.log

cat batch_fit.log | grep 'Ep\. 1 :' | sed -r 's/.*Up\. ([0-9]+) .*Sen. ([,0-9]+).*/\2\/\1/' | sed 's/,//g' | bc > batch_fit.out
$MRT_TOOLS/diff.sh batch_fit.out batch_fit.expected > batch_fit.diff

# Exit with success code
exit 0
