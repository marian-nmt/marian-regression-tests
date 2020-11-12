# Skip if compiled without SentencePiece
test -n "$MRT_MARIAN_USE_SENTENCEPIECE" || exit 100

test -f $MRT_DATA/europarl.de-en/corpus.bpe.de || exit 1
test -f $MRT_DATA/europarl.de-en/corpus.bpe.en || exit 1

test -f train.de.gz || cat $MRT_DATA/europarl.de-en/corpus.bpe.de | sed 's/@@ //g' | head -n 2000 | gzip > train.de.gz
test -f train.en.gz || cat $MRT_DATA/europarl.de-en/corpus.bpe.en | sed 's/@@ //g' | head -n 2000 | gzip > train.en.gz

test -f $MRT_MODELS/rnn-spm/vocab.deen.spm || exit 1
