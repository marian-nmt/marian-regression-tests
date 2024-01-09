#!/usr/bin/env bash

# created by TG on 2023-11-29

set -eux
pairs=(en-de en-ru)
metrics=(chrfoid-wmt23 cometoid22-wmt21 cometoid22-wmt22 cometoid22-wmt23 comet20-da comet20-da-qe bleurt20)
BLOB_URL="https://textmt.blob.core.windows.net/www/models/mt-metric"
DATA_URL="https://textmt.blob.core.windows.net/www/data/marian-regression-tests/metrics.tgz"

METRICS_DIR=$MRT_MODELS/metrics
DATA_DIR=$MRT_DATA/metrics

mkdir -p $METRICS_DIR

# Download metrics data
if [[ ! -f $DATA_DIR._OK ]]; then
    if [[ ! -f $DATA_DIR.tgz || ! -f $DATA_DIR.tgz._OK ]]; then
        rm -f $DATA_DIR.tgz   # remove incomplete downloads
        wget $DATA_URL -O $DATA_DIR.tgz && touch $DATA_DIR.tgz._OK
    fi
    rm -rf $DATA_DIR   # remove incomplete extracts
    mkdir -p $DATA_DIR
    # remove top level dir in archive
    tar -xvzf $DATA_DIR.tgz -C $DATA_DIR --strip-components=1 && touch $DATA_DIR._OK
fi

## DOWNLOAD MODELS
for met in ${metrics[@]}; do
    remote_file="$BLOB_URL/$met.tgz"
    local_file="$METRICS_DIR/$met.tgz"
    local_dir="$METRICS_DIR/$met"
    if [[ ! -d $local_dir || ! -f $local_dir._OK ]]; then
        if [[ ! -f $local_file || ! -f $local_file._OK ]]; then
            rm -f $local_file   # remove incomplete downloads
            wget $remote_file -O $local_file && touch $local_file._OK
        fi
        rm -rf $local_dir   # remove incomplete extracts
        # assumption name of tar has root dir name inside it, so we can extract to METRICS_DIR
        tar -xvzf $local_file -C $METRICS_DIR && touch $local_dir._OK
    fi
done

# verify data
for pair in ${pairs[@]}; do
    test -e $MRT_DATA/metrics/$pair.src
    test -e $MRT_DATA/metrics/$pair.ref
    test -e $MRT_DATA/metrics/$pair.mt
    for met in ${metrics[@]}; do
        test -e $MRT_DATA/metrics/$pair.score.$met.seg.expect || {
            echo "Missing $MRT_DATA/metrics/$pair.score.$met.seg.expect" >&2
            exit 100 #TODO: create the missing .expect files
        }
    done
done
