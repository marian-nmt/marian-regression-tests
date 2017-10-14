#!/bin/bash

# Download single en-de wmt17 model
wget -q --progress=dot --no-clobber -r -e robots=off -nH -np \
    -R *ens2* -R *ens3* -R *ens4* -R *r2l* -R translate-ensemble.sh -R translate-reranked.sh -R index.html* \
    http://data.statmt.org/wmt17_systems/en-de/
# Download additional scripts
wget -q --progress=dot --no-clobber -r -e robots=off -nH -np \
    -R index.html* \
    http://data.statmt.org/wmt17_systems/scripts/ http://data.statmt.org/wmt17_systems/vars
