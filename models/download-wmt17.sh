#!/bin/bash

# Download single en-de wmt17 model
wget -nv -nc -r -e robots=off -nH -np \
    -R *ens2* -R *ens3* -R *ens4* -R *r2l* -R index.html* -R *.meta -R *.data-* -R *.index -R checkpoint \
    -R translate-ensemble.sh -R translate-reranked.sh -R tf-translate-single.sh \
    http://data.statmt.org/wmt17_systems/en-de/
# Download additional scripts
wget -nv -nc -r -e robots=off -nH -np \
    -R index.html* \
    http://data.statmt.org/wmt17_systems/scripts/ http://data.statmt.org/wmt17_systems/vars
