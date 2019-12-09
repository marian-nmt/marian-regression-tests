# Skip if compiled without SentencePiece
if [ ! $MRT_MARIAN_USE_SENTENCEPIECE ]; then
    exit 100
fi

test -f $MRT_MODELS/rnn-spm/model.npz || exit 1
