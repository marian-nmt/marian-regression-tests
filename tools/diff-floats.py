#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import argparse
import re

REGEX_NUMERIC = re.compile(r"^[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?$")
REPLACE_NUMPY = [
    ("[[", "[[ "),
    ("]]", " ]]"),
    ("0. ", "0.0 "),
    ("...) ", "... "),
    ("..., ", "... "),
    ("]", " ]"),
    ("[", "[ ")
]


def is_numeric(s):
    return REGEX_NUMERIC.match(s)


def main():
    args = parse_user_args()
    exit_code = 0
    max_diff_nums = args.max_diff_nums

    i = 0
    while True:
        if args.numpy:
            line1 = ' '.join(args.file1.readlines()).replace('\n', '')
            line2 = ' '.join(args.file2.readlines()).replace('\n', '')

            for k, v in REPLACE_NUMPY:
                line1 = line1.replace(k, v)
                line2 = line2.replace(k, v)
        else:
            line1 = next(args.file1, None)
            if line1 is None:
                break
            line2 = next(args.file2, None)

            if args.separate_nums:
                line1 = line1.replace(args.separate_nums,
                                      ' ' + args.separate_nums + ' ')
                line2 = line2.replace(args.separate_nums,
                                      ' ' + args.separate_nums + ' ')


        line1_toks = line1.rstrip().split()
        line2_toks = line2.rstrip().split()


        nums1 = [float(s) for s in line1_toks if is_numeric(s)]
        nums2 = [float(s) for s in line2_toks if is_numeric(s)]

        text1 = ' '.join(["<NUM>" if is_numeric(s) else s for s in line1_toks])
        text2 = ' '.join(["<NUM>" if is_numeric(s) else s for s in line2_toks])

        if text1 != text2:
            print "Line {}: different texts:\n< {}\n> {}".format( i, text1, text2)
            exit_code = 1
            continue

        if len(nums1) != len(nums2):
            print "Line {}: different number of numerics: {} / {}" \
                .format(i, nums1, nums2)
            exit_code = 1
            continue

        for j, (n1, n2) in enumerate(zip(nums1, nums2)):
            if args.abs:
                n1 = abs(n1)
                n2 = abs(n2)
            if abs(n1 - n2) > args.precision:
                if max_diff_nums < 1:
                    print "Line {}: {} != {}".format(i, n1, n2)
                    exit_code = 1
                else:
                    print "Line {}: {} != {}, allowed diff. numbers: {}" \
                        .format(i, n1, n2, max_diff_nums)
                    max_diff_nums -= 1

        if args.numpy:
            break
        i += 1

    for _ in args.file2:
        print "Extra line in the second file!"
        exit_code = 1

    return exit_code


def parse_user_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("file1", type=argparse.FileType('r'))
    parser.add_argument("file2", type=argparse.FileType('r'))
    parser.add_argument("-p", "--precision", type=float, default=0.001)
    parser.add_argument("-n", "--max-diff-nums", type=int, default=0)
    parser.add_argument("-a", "--abs", action="store_true")
    parser.add_argument("-s", "--separate-nums", type=str)
    parser.add_argument("--numpy", action="store_true")

    return parser.parse_args()


if __name__ == '__main__':
    code = main()
    exit(code)
