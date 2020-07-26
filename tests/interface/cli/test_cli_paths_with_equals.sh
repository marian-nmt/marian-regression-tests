#!/bin/bash

# Exit on error
set -e

rm -rf config_paths.yml

# Create temporary mockup files otherwise marian-decoder will complain instead generating a config file
mkdir -p tmpdir
touch tmpdir/model.npz tmpdir/vocab.yml

# 'input' and 'models' are vector-like options with single values only
$MRT_MARIAN/marian-decoder \
    --input=tmpdir/input.txt \
    --models=tmpdir/model.npz \
    --vocabs=tmpdir/vocab.yml tmpdir/vocab.yml \
    --dim-vocabs=[] \
    --dump-config minimal > config_paths.yml

test -e config_paths.yml

grep -q "input:   - tmpdir/input.txt" <(grep -A1 "input:" config_paths.yml | tr '\n' ' ')
grep -q "models:   - tmpdir/model.npz" <(grep -A1 "models:" config_paths.yml | tr '\n' ' ')
grep -q "vocabs:   - tmpdir/vocab.yml   - tmpdir/vocab.yml" <(grep -A2 "vocabs:" config_paths.yml | tr '\n' ' ')
grep -q "dim-vocabs:   \[\]" <(grep -A1 "dim-vocabs:" config_paths.yml | tr '\n' ' ')

# Exit with success code
exit 0
