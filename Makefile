THREADS=16

GIT_MOSES_SCRIPTS=http://github.com/marian-nmt/moses-scripts.git
GIT_SUBWORD_NMT=http://github.com/rsennrich/subword-nmt.git
GIT_SACREBLEU=http://github.com/marian-nmt/sacreBLEU.git

# Empty value means that all data and models will be downloaded
TARBALLS=

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
	cd $@ && bash ./download-models.sh $(TARBALLS)

data:
	mkdir -p $@
	cd $@ && bash ./download-data.sh $(TARBALLS)

clean:
	git clean -x -d -f tests
	rm -f data/*.tar.gz models/*.tar.gz

clean-all:
	git clean -x -d -f
