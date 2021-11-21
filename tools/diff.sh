#!/bin/bash
#
# Usage:
#   ./diff.sh file1 file2 [number-of-allowed-diff-lines]

[[ "$#" -ge 2 ]] && >&2 echo "Command: $(realpath $0) $(realpath -m $1) $(realpath -m $2)"
diff $1 $2
exitcode=$?
if [ -z "$3" ]; then
  exit $exitcode
else
  numlines=$(diff -y --suppress-common-lines $1 $2 | wc -l)
  >&2 echo "Different lines: $numlines, allowed: $3"
  if [[ "$numlines" -gt "$3" ]]; then
    exit $exitcode
  else
    exit 0
  fi
fi
