test -f $MRT_DATA/europarl.de-en/corpus.bpe.en || exit 1
test -f $MRT_DATA/europarl.de-en/corpus.bpe.de || exit 1
test -f $MRT_DATA/europarl.de-en/toy.bpe.en || exit 1
test -f $MRT_DATA/europarl.de-en/toy.bpe.de || exit 1

test -f $MRT_MODELS/wmt16_systems/en-de/model.npz || exit 1
