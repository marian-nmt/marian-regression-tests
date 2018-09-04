#!/bin/bash

# Download single en-de wmt16 model
wget -nv -nc -r -e robots=off -nH -np -R *r2l* -R index.html* http://data.statmt.org/wmt16_systems/en-de/
