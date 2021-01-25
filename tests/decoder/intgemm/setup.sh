# Skip if compiled without SentencePiece
if [ ! $MRT_MARIAN_USE_SENTENCEPIECE ]; then
    exit 100
fi

test -f $MRT_MODELS/student-eten/model.npz || exit 1
test -f $MRT_MODELS/student-eten/lex.s2t   || exit 1
test -f $MRT_MODELS/student-eten/vocab.spm || exit 1

test -f newstest2018.src || python3 $MRT_TOOLS/sacrebleu/sacrebleu.py -t wmt18 -l et-en --echo src \
    | head -n 100 > newstest2018.src
test -f newstest2018.ref || python3 $MRT_TOOLS/sacrebleu/sacrebleu.py -t wmt18 -l et-en --echo ref \
    | head -n 100 > newstest2018.ref

