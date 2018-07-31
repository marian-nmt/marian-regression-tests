THREADS=16

GIT_MARIAN_DEV=http://github.com/marian-nmt/marian-dev.git
GIT_MARIAN=http://github.com/marian-nmt/marian.git
GIT_MOSES_SCRIPTS=http://github.com/marian-nmt/moses-scripts.git
GIT_SUBWORD_NMT=http://github.com/rsennrich/subword-nmt.git

BRANCH=master
CUDA=/usr/local/cuda
CUDNN=off

CMAKE_FLAGS=-DCUDA_TOOLKIT_ROOT_DIR=$(CUDA) -DUSE_CUDNN=$(CUDNN) -DCMAKE_BUILD_TYPE=Release

PIP_PACKAGES=websocket-client pyyaml

.PHONY: marian install tools models data run
.SECONDARY:


#####################################################################

run: install marian
	bash ./run_mrt.sh

install: tools models data

tools:
	git -C $@/moses-scripts pull || git clone $(GIT_MOSES_SCRIPTS) $@/moses-scripts
	git -C $@/subword-nmt pull || git clone $(GIT_SUBWORD_NMT) $@/subword-nmt
	pip3 install --user $(PIP_PACKAGES)

models:
	mkdir -p $@
	cd $@ && bash ./download-wmt16.sh
	cd $@ && bash ./download-wmt17.sh
	cd $@ && bash ./download-char-s2s.sh
	cd $@ && bash ./download-wnmt18.sh

data:
	mkdir -p $@
	cd $@ && bash ./download-data.sh

marian: tools/marian
tools/marian:
	git -C $@ pull || git clone $(GIT_MARIAN_DEV) -b $(BRANCH) $@
	rm -rf $@/build
	mkdir -p $@/build && cd $@/build && cmake .. -DCOMPILE_EXAMPLES=ON $(CMAKE_FLAGS) && make -j$(THREADS)

