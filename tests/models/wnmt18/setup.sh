test -f $MRT_MODELS/wnmt18/model.student.small/model.npz || exit 1
test -f $MRT_MODELS/wnmt18/model.student.small.aan/model.npz || exit 1

test -f $MRT_MODELS/wnmt18/lex.s2t || exit 1
test -f $MRT_MODELS/wnmt18/newstest2014.bpe.en || exit 1

head -n 100 $MRT_MODELS/wnmt18/newstest2014.bpe.en > newstest2014.in
head -n 100 $MRT_MODELS/wnmt18/newstest2014.de > newstest2014.ref

