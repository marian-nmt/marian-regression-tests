#!/bin/bash

# Exit on error
set -e

rm -rf config_spaces.yml

# Test all types of options
$MRT_MARIAN/marian \
    --quiet-translation true \
    --mini-batch 16 \
    --dropout-rnn 0.3 \
    --type s2s \
    --data-weighting data.txt \
    --dim-vocabs 8000 8000 \
    --sentencepiece-alphas 0.01 0.01 \
    --precision float32 float16 float16 \
    --vocabs vocab.yml vocab.yml \
    --dump-config minimal > config_spaces.yml

test -e config_spaces.yml

grep -q "quiet-translation: true" config_spaces.yml
grep -q "mini-batch: 16" config_spaces.yml
grep -q "dropout-rnn: 0.3" config_spaces.yml
grep -q "type: s2s" config_spaces.yml
grep -q "data-weighting: data.txt" config_spaces.yml
grep -q "dim-vocabs:   - 8000   - 8000" <(grep -A2 "dim-vocabs:" config_spaces.yml | tr '\n' ' ')
grep -q "sentencepiece-alphas:   - 0.01   - 0.01" <(grep -A2 "sentencepiece-alphas:" config_spaces.yml | tr '\n' ' ')
grep -q "precision:   - float32   - float16   - float16" <(grep -A3 "precision:" config_spaces.yml | tr '\n' ' ')
grep -q "vocabs:   - vocab.yml   - vocab.yml" <(grep -A2 "vocabs:" config_spaces.yml | tr '\n' ' ')

# Exit with success code
exit 0
