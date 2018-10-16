#!/bin/bash
grep "Ep\." | sed -r "s/\[....\-..\-.. ..:..:..\] (.*) : Time.*/\\1/"
