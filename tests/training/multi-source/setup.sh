test -f $MRT_DATA/europarl.de-en/corpus.bpe.en || exit 1
test -f $MRT_DATA/europarl.de-en/corpus.bpe.de || exit 1

test -f train.bpe.en || head -n 10000 $MRT_DATA/europarl.de-en/corpus.bpe.en > train.bpe.en
test -f train.bpe.de || head -n 10000 $MRT_DATA/europarl.de-en/corpus.bpe.de > train.bpe.de
test -f train.bpe.xx || sed -e 's/\([^ ]\{,3\}\)[^ ]*/\1/g' -e 's/[.,:;?!()]\s\?//g' train.bpe.en > train.bpe.xx
