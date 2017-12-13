#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import sys

precision = 0.001
if len(sys.argv) > 1:
    precision = float(sys.argv[1])

exit_code = 0

for i, line in enumerate(sys.stdin):
    nums = [float(n) for n in line.rstrip().split("\t")]
    if len(nums) != 2:
        print >>sys.stderr, "Input should contain two real numbers"
        exit(1)
    if abs(nums[0] - nums[1]) > precision:
        print "Line {}: {} != {}".format(i, nums[0], nums[1])
        exit_code = 1

exit(exit_code)
