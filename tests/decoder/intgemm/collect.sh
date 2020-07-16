for f in `ls *.out`; do 
    cp $f $(basename $f .out).avx.expected
    cp $f.bleu $(basename $f .out).avx.expected.bleu
done
