test -f $MRT_DATA/europarl.de-en/corpus.bpe.en || exit 1
test -f $MRT_DATA/europarl.de-en/corpus.bpe.de || exit 1

test -s vocab.de.yml || $MRT_MARIAN/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.de > vocab.de.yml
test -s vocab.en.yml || $MRT_MARIAN/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.en > vocab.en.yml
test -s vocab.de.yml
test -s vocab.en.yml

