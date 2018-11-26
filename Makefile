THREADS=16

GIT_MOSES_SCRIPTS=http://github.com/marian-nmt/moses-scripts.git
GIT_SUBWORD_NMT=http://github.com/rsennrich/subword-nmt.git

PIP_PACKAGES=websocket-client pyyaml

.PHONY: install tools models data run
.SECONDARY:


#####################################################################

run: install
	bash ./run_mrt.sh

install: tools models data

tools:
	git -C $@/moses-scripts pull || git clone $(GIT_MOSES_SCRIPTS) $@/moses-scripts
	git -C $@/subword-nmt pull || git clone $(GIT_SUBWORD_NMT) $@/subword-nmt
	pip3 install --user $(PIP_PACKAGES)
	pip install --user $(PIP_PACKAGES)

models:
	mkdir -p $@
	cd $@ && bash ./download-wmt16.sh
	cd $@ && bash ./download-wmt17.sh
	cd $@ && bash ./download-char-s2s.sh
	cd $@ && bash ./download-wnmt18.sh
	cd $@ && bash ./download-transformer.sh

data:
	mkdir -p $@
	cd $@ && bash ./download-data.sh

clean:
	git clean -x -d -f tests

clean-all:
	git clean -x -d -f
