test -f $MRT_DATA/europarl.de-en/corpus.bpe.en || exit 1
test -f $MRT_DATA/europarl.de-en/corpus.bpe.de || exit 1

test -s vocab.de.yml || $MRT_MARIAN/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.de > vocab.de.yml
test -s vocab.en.yml || $MRT_MARIAN/marian-vocab < $MRT_DATA/europarl.de-en/corpus.bpe.en > vocab.en.yml
test -s vocab.de.yml
test -s vocab.en.yml

test -s corpus.bpe.en || head -n 2000 $MRT_DATA/europarl.de-en/corpus.bpe.en > corpus.bpe.en
test -s corpus.bpe.de || head -n 2000 $MRT_DATA/europarl.de-en/corpus.bpe.de > corpus.bpe.de

test -s corpus.bpe.align || $MRT_MARIAN/marian-scorer -t corpus.bpe.{en,de} -c $MRT_MODELS/wmt16_systems/marian.en-de.scorer.yml --mini-batch 64 --alignment | sed 's/.* ||| //'> corpus.bpe.align
