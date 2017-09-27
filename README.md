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

Each test consists of:

* `test_*.sh` files
* `setup.sh` (optional)
* `teardown.sh` (optional)

## Usage

Download models and compile tools:

```
make install
```

Run regression tests:

```
./run_mrt.sh
```

or a specific group of tests, e.g.:

```
./run_mrt tests/translation
```

## Acknowledgements

The development of Marian received funding from the European Union's
_Horizon 2020 Research and Innovation Programme_ under grant agreements
688139 ([SUMMA](http://www.summa-project.eu); 2016-2019),
645487 ([Modern MT](http://www.modernmt.eu); 2015-2017) and
644333 ([TraMOOC](http://tramooc.eu/); 2015-2017),
the Amazon Academic Research Awards program, and
the World Intellectual Property Organization.

