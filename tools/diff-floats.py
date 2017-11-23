#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import argparse
import re

REGEX_NUMERIC = re.compile(r"^[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?$")


def is_numeric(s):
    return REGEX_NUMERIC.match(s)


def main():
    args = parse_user_args()
    exit_code = 0
    max_diff_nums = args.max_diff_nums

    for i, line1 in enumerate(args.file1):
        line2 = args.file2.next()

        nums1 = [float(s) for s in line1.rstrip().split() if is_numeric(s)]
        nums2 = [float(s) for s in line2.rstrip().split() if is_numeric(s)]

        text1 = ' '.join(["<NUM>" if is_numeric(s) else s
                          for s in line1.rstrip().split()])
        text2 = ' '.join(["<NUM>" if is_numeric(s) else s
                          for s in line2.rstrip().split()])

        if text1 != text2:
            print "Line {}: different texts:\n< {}\n> {}".format(i, text1, text2)
            exit_code = 1
            continue

        if len(nums1) != len(nums2):
            print "Line {}: different number of numerics: {} / {}" \
                .format(i, nums1, nums2)
            exit_code = 1
            continue

        for j, (n1, n2) in enumerate(zip(nums1, nums2)):
            if abs(n1 - n2) > args.precision:
                if max_diff_nums < 1:
                    print "Line {}: {} != {}".format(i, n1, n2)
                    exit_code = 1
                else:
                    print "Line {}: {} != {}, allowed diff. numbers: {}" \
                        .format(i, n1, n2, max_diff_nums)
                    max_diff_nums -= 1

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
    return parser.parse_args()


if __name__ == '__main__':
    code = main()
    exit(code)
