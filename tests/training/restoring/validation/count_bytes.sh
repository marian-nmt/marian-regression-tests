#!/bin/bash

n=$(cat $1 | wc -c)
echo $(($n % 10))
