#!/usr/bin/env bash

set -eu #o pipefail
pairs=(en-de en-ru)
qe_metrics=(chrfoid-wmt23 cometoid22-wmt21 cometoid22-wmt22 cometoid22-wmt23)

        # Skip if no CPU found
if [ ! $MRT_MARIAN_USE_CPU ]; then
    exit 100
fi

readonly metrics=$MRT_MODELS/metrics
readonly max_segs=200
CPU_ARGS="--cpu-threads 2 -w 8000"
GPU_ARGS="--devices 0"  # one gpu
MARIAN_ARGS="$GPU_ARGS --width 4 --like comet-qe --mini-batch 16 --maxi-batch 256 --max-length 512 --max-length-crop true --average skip"


for pair in ${pairs[@]}; do
    test -e $MRT_DATA/metrics/$pair.src
    test -e $MRT_DATA/metrics/$pair.ref
    test -e $MRT_DATA/metrics/$pair.mt
    for met in ${qe_metrics[@]}; do
        prefix=$MRT_DATA/metrics/$pair
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
            | $MRT_MARIAN/marian evaluate -m $model_file -v $vocab_file $vocab_file $MARIAN_ARGS \
            | cut -f1 -d ' ' > $got
        $MRT_TOOLS/diff.sh <(head -n $max_segs $expected) $got > $diff
    done
done
