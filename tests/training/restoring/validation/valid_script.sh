#!/bin/bash

num=$(cat valid_script.temp 2>/dev/null || echo 1)
((num=(num+1)%6))
echo $num > valid_script.temp
((num=6-num))
echo 222.$num
