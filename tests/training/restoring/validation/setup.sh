test -f $MRT_DATA/europarl.de-en/corpus.bpe.en || exit 1
test -f $MRT_DATA/europarl.de-en/corpus.bpe.de || exit 1

test -e $MRT_DATA/train.max50.en
test -e $MRT_DATA/train.max50.de

test -e dev.bpe.de || tail -n 100 $MRT_DATA/europarl.de-en/corpus.bpe.de > dev.bpe.de
test -e dev.bpe.en || tail -n 100 $MRT_DATA/europarl.de-en/corpus.bpe.en > dev.bpe.en

test -e vocab.de.yml || $MRT_MARIAN/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.de > vocab.de.yml
test -e vocab.en.yml || $MRT_MARIAN/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.en > vocab.en.yml
test -e vocab.de.yml
test -e vocab.en.yml
