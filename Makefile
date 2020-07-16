THREADS=16

GIT_MOSES_SCRIPTS=http://github.com/marian-nmt/moses-scripts.git
GIT_SUBWORD_NMT=http://github.com/rsennrich/subword-nmt.git
GIT_SACREBLEU=http://github.com/marian-nmt/sacreBLEU.git

.PHONY: install pip tools models data run
.SECONDARY:


#####################################################################

run: install
	bash ./run_mrt.sh

install: tools models data

tools: pip
	mkdir -p $@
	git -C $@/moses-scripts pull || git clone $(GIT_MOSES_SCRIPTS) $@/moses-scripts
	git -C $@/subword-nmt pull   || git clone $(GIT_SUBWORD_NMT) $@/subword-nmt
	git -C $@/sacrebleu pull     || git clone $(GIT_SACREBLEU) $@/sacrebleu

pip: requirements.txt
	pip3 install --user -r $<

models:
	mkdir -p $@
	cd $@ && bash ./download-wmt16.sh
	cd $@ && bash ./download-wmt17.sh
	cd $@ && bash ./download-char-s2s.sh
	cd $@ && bash ./download-wnmt18.sh
	cd $@ && bash ./download-transformer.sh
	cd $@ && bash ./download-lm.sh
	cd $@ && bash ./download-rnn-spm.sh
	cd $@ && bash ./download-wngt19.sh
	cd $@ && bash ./download-ape.sh
	cd $@ && bash ./download-student-eten.sh

data:
	mkdir -p $@
	cd $@ && bash ./download-data.sh

clean:
	git clean -x -d -f tests

clean-all:
	git clean -x -d -f
