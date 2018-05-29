#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import argparse
import re

REGEX_NUMERIC  = re.compile(r"^[+-]?\d+(?:\.\d+)?(?:[eE][+-]?\d+)?$")
REGEX_STRIP_EP = re.compile(r"^\[valid\] Ep\. \d+ : Up\. ")


def is_numeric(s):
    return REGEX_NUMERIC.match(s)


def process_line(line):
    line = REGEX_STRIP_EP.sub("[valid] ", line)              # normalize new Ep format "[valid] Ep. 1 : Up. 30" -> "[valid] 30"
    line_toks = line.rstrip().replace("[[-", "[[ -").split() # tokenize
    nums = [float(s) for s in line_toks if is_numeric(s)]    # find all numbers
    text = ' '.join(["<NUM>" if is_numeric(s) else s         # text format with numbers normalized
                      for s in line_toks])
    return line_toks, nums, text
    

def main():
    args = parse_user_args()
    exit_code = 0
    max_diff_nums = args.max_diff_nums

    for i, line1 in enumerate(args.file1):
        line2 = args.file2.next()

        line1_toks, nums1, text1 = process_line(line1)
        line2_toks, nums2, text2 = process_line(line2)

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
    return parser.parse_args()


if __name__ == '__main__':
    code = main()
    exit(code)
