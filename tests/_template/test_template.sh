#!/bin/bash

# Exit on error
set -eo pipefail

# Remove any files, etc.
clean_up() {
    echo 
}
trap clean_up EXIT

# Test code goes here
# ...

# Exit with success code
exit 0
