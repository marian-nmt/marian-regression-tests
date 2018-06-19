#!/bin/bash

# Download WNMT18 models
wget -nc -nv -r -np -e robots=off -nH --cut-dirs=3 -R index.html* http://data.statmt.org/romang/marian-regression-tests/models/wnmt18/
