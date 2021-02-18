#!/bin/bash -x 

##################################################################### 
# AUTHOR: pedrodiascoelho
#####################################################################

# Exit on error
set -e

# Test code goes here
test -f $MRT_DATA/europarl.de-en/toy.bpe.en || exit 1
test -f $MRT_DATA/europarl.de-en/toy.bpe.de || exit 1

#escape carachters #:_\| 
test -s toy.bpe.esc.en || cat $MRT_DATA/europarl.de-en/toy.bpe.en | sed 's/#/\&htg;/g;s/:/\&cln;/g;s/_/\&usc;/g;s/\\/\&esc;/g;s/|/\&ppe;/g' \
                                        > toy.bpe.esc.en
test -s toy.bpe.esc.de ||  cat $MRT_DATA/europarl.de-en/toy.bpe.de | sed 's/#/\&htg;/g;s/:/\&cln;/g;s/_/\&usc;/g;s/\\/\&esc;/g;s/|/\&ppe;/g' \
                                        > toy.bpe.esc.de

#add factors to replace @@ markers. s1 is used if a word is a subword (if it has the suffix @@), s0 is used otherwise
test -s toy.bpe.fact.en || cat toy.bpe.esc.en | sed 's/\(\s\|$\)/|s0 /g;s/@@|s0/|s1/g;s/\s*$//' > toy.bpe.fact.en
test -s toy.bpe.fact.de || cat toy.bpe.esc.de | sed 's/\(\s\|$\)/|s0 /g;s/@@|s0/|s1/g;s/\s*$//' > toy.bpe.fact.de

#creates factored vocabulary
if [[ ! -s vocab.en.fsv ]]; then
  echo '_lemma

_s
s0 : _s
s1 : _s

</s> : _lemma
<unk> : _lemma' > vocab.en.fsv

  sed -i 's/@@//g' toy.bpe.esc.en
  $MRT_MARIAN/marian-vocab < toy.bpe.esc.en | grep -v '<\/s>\|<unk>' | sed 's/"//g' | sed 's/:.*$/ : _lemma _has_s/' >> vocab.en.fsv
fi

if [[ ! -s vocab.de.fsv ]]; then
  echo '_lemma

_s
s0 : _s
s1 : _s

</s> : _lemma
<unk> : _lemma' > vocab.de.fsv

  sed -i 's/@@//g' toy.bpe.esc.de
  $MRT_MARIAN/marian-vocab < toy.bpe.esc.de | grep -v '<\/s>\|<unk>' | sed 's/"//g' | sed 's/:.*$/ : _lemma _has_s/' >> vocab.de.fsv
fi

# Exit with success code
exit 0
