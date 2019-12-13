test -f $MRT_DATA/europarl.de-en/corpus.bpe.en || exit 1
test -f $MRT_DATA/europarl.de-en/corpus.bpe.de || exit 1

test -e vocab.de.yml || $MRT_MARIAN/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.de > vocab.de.yml
test -e vocab.en.yml || $MRT_MARIAN/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.en > vocab.en.yml
test -e vocab.de.yml
test -e vocab.en.yml


test -e vocab.ende.yml || cat $MRT_DATA/europarl.de-en/corpus.bpe.{en,de} | $MRT_MARIAN/marian-vocab > vocab.ende.yml
