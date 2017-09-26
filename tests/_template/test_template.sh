#!/bin/bash

# Exit on error
set -e

# Remove any files, etc.
clean_up() {
    echo 
}
trap clean_up EXIT

# Test code goes here
# ...

# Exit with success code
exit 0
