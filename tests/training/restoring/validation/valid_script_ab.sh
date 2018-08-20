#!/bin/bash

if [[ -z $1 ]]; then
    num=$(cat valid_script_a.temp 2>/dev/null || echo 2)
    ((num=(num+1)%6))
    echo $num > valid_script_a.temp
    ((num=6-num))
    echo 222.$num
else
    num=$(cat valid_script_b.temp 2>/dev/null || echo 3)
    ((num=(num+1)%9))
    echo $num > valid_script_b.temp
    ((num=9-num))
    echo 333.$num
fi
