
import sys

for line in sys.stdin:
    txt, aln = line.strip().split(' ||| ')
    ps = [a.split('-') for a in aln.split()]
    idxs = [(int(p[1]), int(p[0])) for p in ps]
    idxs.sort()
    aln2 = " ".join(["{}-{}".format(a, b) for a, b in idxs])
    print("{} ||| {}".format(txt, aln2))
