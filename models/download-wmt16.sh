#!/bin/bash

# Download all en-de wmt16 models
wget -nv -nc -r -e robots=off -nH -np -R '*r2l*' -R 'index.html*' http://data.statmt.org/wmt16_systems/en-de/

# Download single de-en wmt16 model
wget -nv -nc -r -e robots=off -nH -np -R '*r2l*' -R '*-ens*' -R '*.sh' -R 'index.html*' http://data.statmt.org/wmt16_systems/de-en/
