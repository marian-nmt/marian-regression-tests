# Skip if compiled without SentencePiece
if [ ! $MRT_MARIAN_USE_SENTENCEPIECE ]; then
    exit 100
fi

test -f $MRT_DATA/europarl.de-en/corpus.en || exit 1
test -f $MRT_DATA/europarl.de-en/corpus.de || exit 1
