#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import argparse
import re

REGEX_NUMERIC  = re.compile(r"^[+-]?\d+(?:(?:,\d\d\d)+|(?:\d+))*(?:\.\d+)?(?:[eE][+-]?\d+)?$")
REGEX_STRIP_EP = re.compile(r"^\[valid\] Ep\. \d+ : Up\. ")

NORMALIZE_NUMPY = [
    ("[[", "[[ "),
    ("]]", " ]]"),
    ("0. ", "0.0 "),
    ("...) ", "... "),
    ("..., ", "... "),
    ("]", " ]"),
    ("[", "[ "),
]


def main():
    args = parse_user_args()
    display_command(args)

    exit_code = 0
    allowed_diffs = args.allow_n_diffs
    args.message_count = 0

    i = 0
    while True:
        i += 1

        if args.numpy:
            line1 = read_numpy(args.file1)
            line2 = read_numpy(args.file2)
        else:
            line1 = read_line(args.file1, args.separate)
            if line1 is None:
                break
            line2 = read_line(args.file2, args.separate)
            if line2 is None:
                break

        line1_toks, nums1, text1 = process_line(line1)
        line2_toks, nums2, text2 = process_line(line2)

        if text1 != text2:
            message("Line {}: different texts:\n< {}\n> {}".format(i, text1, text2), args)
            exit_code = 1
            continue

        if len(nums1) != len(nums2):
            message("Line {}: different number of numerics: {} / {}".format(i, nums1, nums2), args)
            exit_code = 1
            continue

        for j, (n1, n2) in enumerate(zip(nums1, nums2)):
            if args.abs:
                n1 = abs(n1)
                n2 = abs(n2)
            if abs(n1 - n2) > args.precision:
                if allowed_diffs < 1:
                    message("Line {}: {} != {}".format(i, n1, n2), args)
                    exit_code = 1
                else:
                    message("Line {}: {} != {}, allowed number of differences: {}" \
                                .format(i, n1, n2, allowed_diffs),
                            args)
                    allowed_diffs -= 1

        if args.numpy:
            break

    for _ in args.file1:
        message("Extra line in the first file", args)
        exit_code = 1

    for _ in args.file2:
        message("Extra line in the second file", args)
        exit_code = 1

    return exit_code


def read_numpy(iofile):
    line = ' '.join(iofile.readlines()).replace('\n', '')   # merge all lines
    for k, v in NORMALIZE_NUMPY:                            # normalize numpy format across Python/Numpy versions
        line = line.replace(k, v)
    return line


def read_line(iofile, separator=""):
    line = next(iofile, None)
    if separator and line:
        line = line.replace(separator, ' ' + separator + ' ')   # add spaces around the separator character
    return line


def process_line(line):
    line = REGEX_STRIP_EP.sub("[valid] ", line)                 # normalize "[valid] Ep. 1 : Up. 30" -> "[valid] 30"
    line = line.replace("(", "( ").replace(")", " )")           # insert space before and after parentheses
    line_toks = line.rstrip().replace("[[-", "[[ -").split()    # tokenize
    nums = [float(s.replace(',', ''))                           # handle comma as thousands separator
            for s in line_toks if is_numeric(s)]                # find all numbers
    text = ' '.join(["<NUM>" if is_numeric(s) else s            # text format with numbers normalized
                      for s in line_toks])
    return line_toks, nums, text


def is_numeric(s):
    return REGEX_NUMERIC.match(s)


def message(text, args):
    if not text.endswith("\n"):
        text += "\n"
    args.output.write(text)
    args.message_count += 1
    if not args.quiet \
            and args.output is not sys.stdout \
            and args.output is not sys.stderr:
        sys.stderr.write(text)


def display_command(args):
    if args.quiet:
        return
    opts = [sys.argv[0]]
    for opt in sys.argv[1:]:
        # expand relative paths
        if opt == args.file1.name or opt == args.file2.name or opt == args.output.name:
            opts.append(os.path.abspath(opt))
        else:
            opts.append(opt)
    sys.stderr.write("Command: {}\n".format(" ".join(opts)))


def parse_user_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("file1", type=argparse.FileType('r'))
    parser.add_argument("file2", type=argparse.FileType('r'))
    parser.add_argument("-o", "--output", type=argparse.FileType('w'), metavar="FILE", default=sys.stdout)
    parser.add_argument("-p", "--precision", type=float, metavar="FLOAT", default=0.001)
    parser.add_argument("-n", "--allow-n-diffs", type=int, metavar="INT", default=0)
    parser.add_argument("-s", "--separate", type=str, metavar="STRING")
    parser.add_argument("-a", "--abs", action="store_true")
    parser.add_argument("--numpy", action="store_true")
    parser.add_argument("-q", "--quiet", action="store_true")
    return parser.parse_args()


if __name__ == '__main__':
    code = main()
    exit(code)
