THREADS=16

GIT_MARIAN_DEV=http://github.com/marian-nmt/marian-dev.git
GIT_MARIAN=http://github.com/marian-nmt/marian.git
GIT_MOSES_SCRIPTS=http://github.com/marian-nmt/moses-scripts.git
GIT_SUBWORD_NMT=http://github.com/rsennrich/subword-nmt.git

.PHONY: tools/marian-dev tools/marian install tools models data run
.SECONDARY:


#####################################################################

install: tools models data

run: install
	bash ./run_mrt.sh

tools: tools/marian
	git -C $@/moses-scripts pull || git clone $(GIT_MOSES_SCRIPTS) $@/moses-scripts
	git -C $@/subword-nmt pull || git clone $(GIT_SUBWORD_NMT) $@/subword-nmt

tools/marian:
	git -C $@ pull || git clone $(GIT_MARIAN_DEV) $@
	mkdir -p $@/build && cd $@/build && cmake .. -DCOMPILE_EXAMPLES=ON -DUSE_CUDNN=ON && make -j$(THREADS)

models:
	mkdir -p $@
	cd $@ && bash ./download-wmt16.sh
	cd $@ && bash ./download-wmt17.sh

data:
	mkdir -p $@
	cd $@ && bash ./download-data.sh
