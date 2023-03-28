#!/bin/bash

prefix=eps_stop_script

num1=$(cat $prefix.temp 2>/dev/null || echo 112)
((num1=2+num1))
echo $num1 > $prefix.temp
#(( num1 > 5 )) && num2=2 || num2=1
num2=$(echo -n "$num1" | cut -c1-2)
((num1=num1%7))
echo $num2.$num1
