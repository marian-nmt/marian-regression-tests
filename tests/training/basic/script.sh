#!/bin/bash

echo line written at $(date) >> script.temp 2> /dev/null
wc -l script.temp
