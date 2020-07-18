for f in `ls *.out`; do 
    cp $f $(basename $f .out).avx2.expected
    #cp $f.bleu $(basename $f .out).avx2.expected.bleu
done
