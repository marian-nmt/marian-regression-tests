THREADS=16

GIT_MARIAN_DEV=http://github.com/marian-nmt/marian-dev.git
GIT_MARIAN=http://github.com/marian-nmt/marian.git
GIT_MOSES_SCRIPTS=http://github.com/marian-nmt/moses-scripts.git
GIT_SUBWORD_NMT=http://github.com/rsennrich/subword-nmt.git
GIT_NEMATUS=http://github.com/EdinburghNLP/nematus.git

BRANCH=master
USE_CUDNN=ON

.PHONY: tools/marian install tools models data run
.SECONDARY:


#####################################################################

install: tools tools/marian models data

run: install
	bash ./run_mrt.sh

tools:
	git -C $@/moses-scripts pull || git clone $(GIT_MOSES_SCRIPTS) $@/moses-scripts
	git -C $@/subword-nmt pull || git clone $(GIT_SUBWORD_NMT) $@/subword-nmt
	git -C $@/nematus pull || git clone $(GIT_NEMATUS) $@/nematus
	pip3 install websocket websocket-client

tools/marian:
	git -C $@ pull || git clone $(GIT_MARIAN_DEV) -b $(BRANCH) $@
	mkdir -p $@/build && cd $@/build && cmake .. -DCOMPILE_EXAMPLES=ON -DUSE_CUDNN=$(USE_CUDNN) && make -j$(THREADS)

models:
	mkdir -p $@
	cd $@ && bash ./download-wmt16.sh
	cd $@ && bash ./download-wmt17.sh
	cd $@ && bash ./download-char-s2s.sh

data:
	mkdir -p $@
	cd $@ && bash ./download-data.sh
