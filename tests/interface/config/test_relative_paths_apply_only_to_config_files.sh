#!/bin/bash

# Exit on error
set -e

rm -f relpaths_to_cfgfile.log

# Test code goes here
echo "this is a test" | $MRT_MARIAN/marian-decoder -c relpaths_to_cfgfile.yml -m ../../../models/wmt16_systems/en-de/model.npz --log relpaths_to_cfgfile.log

test -e relpaths_to_cfgfile.log

# Check if relative paths from command-line options are untouched
grep -q "\.\./\.\./\.\./models/wmt16_systems/en-de/model.npz" relpaths_to_cfgfile.log
# Check if relative paths from the config file are expanded
if ! grep -q "\.\./\.\./\.\./models/wmt16_systems/en-de/vocab\...\.json" relpaths_to_cfgfile.log; then exit 0; else exit 1; fi

# Exit with success code
exit 0
