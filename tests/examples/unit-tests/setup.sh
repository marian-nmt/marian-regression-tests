#!/bin/bash

# Exit on error
set -e

# Setup code goes here
test -n "$MRT_MARIAN_USE_UNITTESTS" || exit $EXIT_CODE_SKIP

# Exit with success code
exit 0
