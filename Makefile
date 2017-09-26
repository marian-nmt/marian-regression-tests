
THREADS=16

GIT_MARIAN=http://github.com/marian-nmt/marian-dev.git
GIT_MOSES_SCRIPTS=http://github.com/marian-nmt/moses-scripts.git

URL_MODELS=

.PHONY: marian install
.SECONDARY:


install: marian/build/marian

download:
	test $(URL_MODELS) && wget -q --show-progress $(URL_MODELS)

#####################################################################

marian/build/marian: marian
	mkdir -p $</build && cd $</build && cmake .. -DCOMPILE_EXAMPLES=ON -DUSE_CUDNN=ON && make -j$(THREADS)

marian:
	git -C $@ pull || git clone $(GIT_MARIAN) $@
