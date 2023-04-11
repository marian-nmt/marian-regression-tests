#!/bin/bash -x

#####################################################################
# DESCRIPTION: Check if --after +NU increment existing --after value
# AUTHOR: snukky
# TAGS: after relative-after
#####################################################################

# Exit on error
set -e

# Test code goes here
rm -rf after after_cmd.yml
mkdir -p after

echo "after: 50u" > config1.yml

$MRT_MARIAN/marian \
    --no-shuffle --clip-norm 0 --seed 1111 --optimizer sgd --dim-emb 64 --dim-rnn 128 \
    -m after/model.npz -t train.bpe.{en,de} -v vocab.spm vocab.spm \
    -c config1.yml --after +20u --dump-config minimal > after_cmd.yml

# Check if --after was incremented
test -e after_cmd.yml
grep -q "after: 70u" after_cmd.yml

# Exit with success code
exit 0
