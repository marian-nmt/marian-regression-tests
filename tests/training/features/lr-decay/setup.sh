test -f $MRT_DATA/europarl.de-en/corpus.bpe.en || exit 1
test -f $MRT_DATA/europarl.de-en/corpus.bpe.de || exit 1

test -f $MRT_MODELS/wngt19/model.small.npz || exit 1
test -f $MRT_MODELS/wngt19/newstest2014.en || exit 1
test -f $MRT_MODELS/wngt19/newstest2014.de || exit 1
