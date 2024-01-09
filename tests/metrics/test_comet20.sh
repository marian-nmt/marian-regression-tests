#!/usr/bin/env bash

set -eu #o pipefail
pairs=(en-de en-ru)

# Skip if no CPU found
if [ ! $MRT_MARIAN_USE_CPU ]; then
    exit 100
fi

readonly metrics=$MRT_MODELS/metrics
readonly max_segs=16
CPU_ARGS="--cpu-threads 8 -w 8000 --mini-batch 4"
GPU_ARGS="--devices 0 --mini-batch 16"  # one gpu
MARIAN_ARGS="$CPU_ARGS --width 4 --maxi-batch 256 --max-length 512 --max-length-crop true --average skip"


for pair in ${pairs[@]}; do
    test -e $MRT_DATA/metrics/$pair.src
    test -e $MRT_DATA/metrics/$pair.ref
    test -e $MRT_DATA/metrics/$pair.mt
    prefix=$MRT_DATA/metrics/$pair
    
    #reference less comet20
    met=comet20-da-qe
    expected=$prefix.score.$met.seg.expect
    got=$prefix.score.$met.seg.got
    diff=$prefix.score.$met.seg.diff
    rm -f $got $diff
    
    model_file=$(echo $metrics/$met/model*.npz)
    vocab_file=$(echo $metrics/$met/vocab*.spm)
    test -e $model_file
    test -e $vocab_file
    paste $prefix.src $prefix.mt \
        | head -n $max_segs \
        | $MRT_MARIAN/marian evaluate --like comet-qe  -m $model_file -v $vocab_file $vocab_file $MARIAN_ARGS \
        | cut -f1 -d ' ' > $got

    test -e $expected
    $MRT_TOOLS/diff-nums.py <(head -n $max_segs $expected) $got > $diff

    # reference based comet20
    met=comet20-da
    expected=$prefix.score.$met.seg.expect
    got=$prefix.score.$met.seg.got
    diff=$prefix.score.$met.seg.diff
    rm -f $got $diff
    
    model_file=$(echo $metrics/$met/model*.npz)
    vocab_file=$(echo $metrics/$met/vocab*.spm)
    test -e $model_file
    test -e $vocab_file
    paste $prefix.src $prefix.mt $prefix.ref \
        | head -n $max_segs \
        | $MRT_MARIAN/marian evaluate --like comet -m $model_file -v $vocab_file $vocab_file $vocab_file  $MARIAN_ARGS \
        | cut -f1 -d ' ' > $got

    test -e $expected
    $MRT_TOOLS/diff-nums.py <(head -n $max_segs $expected) $got > $diff
done
