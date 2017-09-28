#!/bin/bash

# Exit on error
set -e

# Remove any files, etc.
clean_up() {
    rm -f iris.out
}
trap clean_up EXIT

# Test code goes here
$MRT_MARIAN/build/iris_example > iris.out
diff iris.out iris.expected > iris.diff

# Exit with success code
exit 0
