#!/bin/bash

#####################################################################
# SUMMARY: Path to a lexical shortlist can be relative in the config file
# TAGS: config shortlist
#####################################################################

# Exit on error
set -e

rm -f relpaths_shortlist.log

# Test code goes here
echo "Das ist ein Test." \
    | $MRT_MARIAN/marian-decoder -c subdir/relpaths_shortlist.yml --log relpaths_shortlist.log \
    > relpaths_shortlist.out

test -e relpaths_shortlist.log
test -e relpaths_shortlist.out

# Check if relative paths from config files have been expanded
if ! grep -q "\.\./\.\./" relpaths_shortlist.log; then exit 0; else exit 1; fi

# Check the output
$MRT_TOOLS/diff.sh relpaths_shortlist.out relpaths_shortlist.expected > relpaths_shortlist.diff

# Exit with success code
exit 0
