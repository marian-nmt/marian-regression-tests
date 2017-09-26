
THREADS=16

GIT_MARIAN=http://github.com/marian-nmt/marian-dev.git
GIT_MOSES_SCRIPTS=http://github.com/marian-nmt/moses-scripts.git
GIT_SUBWORD_NMT=http://github.com/rsennrich/subword-nmt.git

URL_MODELS=

.PHONY: marian install
.SECONDARY:


install: marian/build/marian tools

tools:
	mkdir -p $@
	cd $@ && git clone $(GIT_MOSES_SCRIPTS)
	cd $@ && git clone $(GIT_SUBWORD_NMT)

models:
	mkdir -p $@
	cd $@ && bash download_wmt16.sh

#####################################################################

marian/build/marian: marian
	mkdir -p $</build && cd $</build && cmake .. -DCOMPILE_EXAMPLES=ON -DUSE_CUDNN=ON && make -j$(THREADS)

marian:
	git -C $@ pull || git clone $(GIT_MARIAN) $@
