test -f $MRT_MODELS/wmt16_systems/en-de/model.npz || exit 1

test -f $MRT_MODELS/wmt18/entr/model.rnn.A.npz || exit 1
test -f $MRT_MODELS/wmt18/entr/model.rnn.B.npz || exit 1

test -f dev2016.in || head -n 50 $MRT_MODELS/wmt18/entr/dev2016.bpe.en > dev2016.in
test -f dev2016.in || exit 1
test -f $MRT_MODELS/wmt18/entr/model.rnn.A.npz || exit 1
test -f $MRT_MODELS/wmt18/entr/model.rnn.B.npz || exit 1

test -f dev2016.in || head -n 50 $MRT_MODELS/wmt18/entr/dev2016.bpe.en > dev2016.in
test -f dev2016.in || exit 1
