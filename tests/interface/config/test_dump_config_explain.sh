#!/bin/bash

# Exit on error
set -e

rm -f dump_explain.{yml,out}

# Run with no config file
$MRT_MARIAN/marian --best-deep --type s2s --mini-batch 8 --dim-rnn 32 --dim-emb 16 --after-batches 2 --dump-config explain > dump_explain.yml

# Remove first line and paths to train sets and vocabs
cat dump_explain.yml | tail -n +2 | grep -v '  - ' > dump_explain.out

# Compare
$MRT_TOOLS/diff.sh dump_explain.out dump_explain.expected > dump_explain.diff

# Exit with success code
exit 0
