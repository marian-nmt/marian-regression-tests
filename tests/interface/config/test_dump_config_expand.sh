#!/bin/bash

#####################################################################
# SUMMARY: Test expanding alias options when dumping to a config file
# AUTHOR: snukky
# TAGS: future
#####################################################################

# Exit on error
set -e

rm -f dump_expand.{yml,out}

# Run with no config file
$MRT_MARIAN/marian --best-deep --type s2s --mini-batch 8 --dim-rnn 32 --dim-emb 16 --after-batches 2 --dump-config expand > dump_expand.yml

# Remove first line and paths to train sets and vocabs
cat dump_expand.yml | tail -n +2 | grep -v '  - ' > dump_expand.out

# Compare
$MRT_TOOLS/diff.sh dump_expand.out dump_expand.expected > dump_expand.diff

# Exit with success code
exit 0
