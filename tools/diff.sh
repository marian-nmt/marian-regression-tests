#!/bin/bash
[[ "$#" -eq 2 ]] && >&2 echo "Command: $(realpath $0) $(realpath -m $1) $(realpath -m $2)"
diff $1 $2
