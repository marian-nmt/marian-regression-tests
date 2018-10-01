Marian regression tests
=======================

<b>Marian</b> is an efficient Neural Machine Translation framework written in
pure C++ with minimal dependencies.

This repository contains the regression test framework for the main development
repository: `https://github.com/marian-nmt/marian-dev`.


## Structure

Directories:

* `tests` - regression tests
* `tools` - scripts and repositories
* `models` - models used in regression tests
* `data` - data used in training or decoding tests

Each test consists of:

* `test_*.sh` file
* `setup.sh` (optional)
* `teardown.sh` (optional)


## Usage

Downloading data and tools, compiling the most recent version of marian-dev, and running
single-GPU tests:

    make install
    make marian
    make run
    # or simply make

Testing a custom version of Marian:

    make install
    MARIAN=/path/to/marian-dev ./run_mrt.sh

Enabling multi-GPU tests:

    CUDA_VISIBLE_DEVICES=0,1 ./run_mrt.sh

More invocation examples:

    ./run_mrt.sh tests/training/basics
    ./run_mrt.sh tests/training/basics/test_valid_script.sh
    ./run_mrt.sh previous.log

where _previous.log_ contains a list of test files in separate lines.

Clean test artifacts:

    make clean


## Adding new tests

Use templates provided in `tests/_template`.

Please follow these recommendations:

* For comparing outputs with numbers, please use float-friendly
  `tools/diff-floats.py` instead of GNU `diff`
* Make your tests deterministic using `--no-shuffle --seed 1111` or similar
* Make training execution as short as possible, for instance, by reducing the
  size of the network and the number of iterations
* Do not run decoding or scoring on files longer than ca. 10-100 lines
* If your tests require downloading and running a custom model, please keep it
  as small as possible, and contact one of the main contributors to upload it
  into our storage
* Test one thing at a time


## Acknowledgements

The development of Marian received funding from the European Union's
_Horizon 2020 Research and Innovation Programme_ under grant agreements
688139 ([SUMMA](http://www.summa-project.eu); 2016-2019),
645487 ([Modern MT](http://www.modernmt.eu); 2015-2017),
644333 ([TraMOOC](http://tramooc.eu/); 2015-2017),
644402 ([HiML](http://www.himl.eu/); 2015-2017),
the Amazon Academic Research Awards program,
the World Intellectual Property Organization,
and is based upon work supported in part by the Office of the Director of
National Intelligence (ODNI), Intelligence Advanced Research Projects Activity
(IARPA), via contract #FA8650-17-C-9117.

This software contains source code provided by NVIDIA Corporation.

