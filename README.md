Marian regression tests
=======================

**Marian** is a C++ GPU-specific parallel automatic differentiation library
with operator overloading. It is the training framework used in the Marian
toolkit.

This repository contains the regression test framework for the repo of
`https://github.com/marian-nmt/marian-dev`.


## Structure

Directories:

* `tests` - regression tests
* `tools` - scripts and repositories
* `models` - models used in regression tests
* `data` - data used in training or decoding tests

Each test consists of:

* `test_*.sh` files
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

