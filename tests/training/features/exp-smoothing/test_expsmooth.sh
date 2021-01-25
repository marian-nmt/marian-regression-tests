#!/bin/bash -x

# Exit on error
set -e

# Test code goes here
rm -rf expsmooth expsmooth*.log
mkdir -p expsmooth


opts="--no-shuffle --seed 777 --mini-batch 4 --maxi-batch 1 --maxi-batch-sort none --dim-rnn 64 --dim-emb 32 --optimizer sgd --learn-rate 0.5 --valid-sets valid.bpe.en valid.bpe.de --valid-metrics cross-entropy --valid-mini-batch 32 --cost-type ce-mean"

# No exponential smoothing
$MRT_MARIAN/marian \
    -m expsmooth/model.noexp.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 20 --valid-freq 20 --after-batches 200 $opts \
    --log expsmooth_0.log

test -e expsmooth/model.noexp.npz
test -e expsmooth_0.log

cat expsmooth_0.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid' | sed 's/ : Time.*//' > noexpsmooth.out
#cat expsmooth_0.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > noexpsmooth.valid.out


# With exponential smoothing
$MRT_MARIAN/marian \
    -m expsmooth/model.npz -t $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} -v vocab.en.yml vocab.de.yml \
    --disp-freq 20 --valid-freq 20 --after-batches 200 --exponential-smoothing 0.0001 $opts \
    --log expsmooth.log

test -e expsmooth/model.npz
test -e expsmooth.log

cat expsmooth.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep -v 'valid' | sed 's/ : Time.*//' > expsmooth.out
cat expsmooth.log | $MRT_TOOLS/strip-timestamps.sh | grep "Ep\. " | grep 'valid' | sed 's/ : Time.*//' > expsmooth.valid.out


$MRT_TOOLS/diff-nums.py -p 0.01 expsmooth.out expsmooth.expected -o expsmooth.diff
$MRT_TOOLS/diff-nums.py -p 0.01 expsmooth.valid.out expsmooth.valid.expected -o expsmooth.valid.diff

# There should be no difference in costs between training w/ and w/o exponential smoothing
$MRT_TOOLS/diff-nums.py -p 0.001 expsmooth.out noexpsmooth.out -o noexpsmooth.diff


# Exit with success code
exit 0
