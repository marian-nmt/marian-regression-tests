#!/bin/bash

# Exit on error
set -e

# Test code goes here
timeout 10 python subprocess_script.py $MRT_MARIAN $MRT_MODELS/wmt16_systems/marian.en-de.yml text.in > subprocess.out
$MRT_TOOLS/diff.sh subprocess.out subprocess.expected > subprocess.diff

# Exit with success code
exit 0
