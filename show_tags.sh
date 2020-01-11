#!/bin/bash

if [ $# -ge 1 ]; then
    tags=$@
else
    tags=$(find tests -name '*test_*.sh' | xargs -i grep '^ *# *TAGS:' {} | sed 's/ *# *TAGS: *//' | tr ' ' '\n' | sort | uniq)
fi

for tag in $tags; do
    echo "#$tag"
    find tests -name '*test_*.sh' | xargs -i grep -l "^ *# *TAGS:.* $tag" {} | sed -e 's/ *# *TAGS: */ /' -e 's/^/ - /'
    echo
done
