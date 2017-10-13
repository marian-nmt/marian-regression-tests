#!/bin/bash

# Download single en-de wmt16 model
wget -r -e robots=off -nH -np \
    -R *ens* -R *r2l* -R index.html* \
    http://data.statmt.org/wmt16_systems/en-de/
