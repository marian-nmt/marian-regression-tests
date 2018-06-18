#!/bin/bash
sed -r "s/^BLEU = ([0-9]+\.[0-9]+), .*/\1/"
