#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import argparse
import re

import numpy as np

def main():
    exit_code = 0
    args = parse_user_args()

    with np.load(args.file) as data:
      for key in data:
        # skip special:model.yml
        if "special" in key:
          continue
       
        # if one of the dimension is 1, then it is a bias
        # skip if it is bias and bias is not included
        smallest_dim = sorted(data[key].shape)[0]
        if(smallest_dim == 1 and not args.with_bias):
          continue

        if (np.unique(data[key]).size > 2**args.bits):
          message("Tensor {} has more than {} unique values".format( \
                   key, \
                   2**args.bits), args)
          exit_code = 1
        if (args.print_centers):
          message("Tensor {} unique centers: {}".format(key, np.unique(data[key])), args)    
    return exit_code


def message(text, args):
    if not text.endswith("\n"):
        text += "\n"
    args.output.write(text)
    if not args.quiet \
            and args.output is not sys.stdout \
            and args.output is not sys.stderr:
        sys.stderr.write(text)


def parse_user_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("file", type=str)
    parser.add_argument("-o", "--output", type=argparse.FileType('w'), metavar="FILE", default=sys.stdout)
    parser.add_argument("--print_centers", action="store_true")
    parser.add_argument("-b", "--bits", type=int)
    parser.add_argument("--with_bias", action="store_true") 
    parser.add_argument("-q", "--quiet", action="store_true")
    return parser.parse_args()

if __name__ == '__main__':
    code = main()
    exit(code)
