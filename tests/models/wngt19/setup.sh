# Skip if compiled without SentencePiece
if [ ! $MRT_MARIAN_USE_SENTENCEPIECE ]; then
    exit 100
fi

test -f $MRT_MODELS/wngt19/model.base.npz || exit 1
test -f $MRT_MODELS/wngt19/model.small.npz || exit 1
test -f $MRT_MODELS/wngt19/model.tiny1.npz || exit 1

test -f $MRT_MODELS/wngt19/en-de.spm || exit 1
test -f $MRT_MODELS/wngt19/lex.s2t.gz || exit 1

head -n 100 $MRT_MODELS/wngt19/newstest2014.en > newstest2014.in
head -n 100 $MRT_MODELS/wngt19/newstest2014.de > newstest2014.ref

