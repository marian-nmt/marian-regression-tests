#!/bin/bash

# Exit on error
set -e

# Test code goes here
rm -f envvars.out

export MRTMODELDIR=wmt16_systems
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/'${MRTMODELDIR}'/marian.en-de.yml --interpolate-env-vars -i text.in > envvars.out
$MRT_TOOLS/diff.sh envvars.out text.expected > envvars.diff

# Without --interpolate-env-vars this should fail
$MRT_MARIAN/marian-decoder -c $MRT_MODELS/'${MRTMODELDIR}'/marian.en-de.yml -i text.in > envvars.log 2>&1 || true
grep -q "does not exist" envvars.log

# Exit with success code
exit 0
