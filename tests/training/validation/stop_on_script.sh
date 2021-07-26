#!/bin/bash

prefix=stop_on_script

num=$(cat $prefix.temp 2>/dev/null || echo 1)
((num=(num+1)%6))
echo $num > $prefix.temp
((num=6-num))
echo 111.$num
