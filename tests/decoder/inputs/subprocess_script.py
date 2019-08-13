#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from subprocess import Popen, PIPE


marian_path = sys.argv[1]
config_file = sys.argv[2]
text_file = sys.argv[3]


cmd = ["{}/marian-decoder".format(marian_path), "-c", config_file, "--log", "subprocess.log"]
sys.stdout.write("Command: {}\n".format(cmd))
p = Popen(cmd, stdin=PIPE, stdout=PIPE, stderr=PIPE)


with open(text_file) as f:
    text = f.readlines()[:10]

for sent in text:
    sys.stdout.write("Sending:   {}".format(sent))
    p.stdin.write(sent)
    p.stdin.flush()
    out = p.stdout.readline()
    sys.stdout.write("Receiving: {}".format(out))

p.stdin.close()
p.terminate()
