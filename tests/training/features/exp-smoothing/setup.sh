test -f $MRT_DATA/europarl.de-en/corpus.bpe.en || exit 1
test -f $MRT_DATA/europarl.de-en/corpus.bpe.de || exit 1

test -f valid.bpe.en | tail -n 32 $MRT_DATA/europarl.de-en/corpus.bpe.en > valid.bpe.en
test -f valid.bpe.de | tail -n 32 $MRT_DATA/europarl.de-en/corpus.bpe.de > valid.bpe.de

