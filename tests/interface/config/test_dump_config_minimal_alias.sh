#!/bin/bash

#####################################################################
# SUMMARY: Test dumping minimum needed options to a config file when using an alias
# AUTHOR: snukky
# TAGS: future
#####################################################################

# Exit on error
set -e

rm -f dump_alias.{yml,out}

# Run with no config file
$MRT_MARIAN/marian --best-deep --type s2s --mini-batch 8 --dim-rnn 32 --dim-emb 16 --after-batches 2 --dump-config minimal > dump_alias.yml

# Remove first line and paths to train sets and vocabs
cat dump_alias.yml | tail -n +2 | grep -v '  - ' > dump_alias.out

# Compare
$MRT_TOOLS/diff.sh dump_alias.out dump_alias.expected > dump_alias.diff

# Exit with success code
exit 0
