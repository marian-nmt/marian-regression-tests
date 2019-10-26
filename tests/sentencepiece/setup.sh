# Skip if compiled without SentencePiece
if [ ! $MRT_MARIAN_USE_SENTENCEPIECE ]; then
    exit 100
fi

test -f $MRT_DATA/europarl.de-en/corpus.small.en.gz || exit 1
test -f $MRT_DATA/europarl.de-en/corpus.small.de.gz || exit 1

test -f $MRT_MODELS/rnn-spm/model.npz || exit 1
