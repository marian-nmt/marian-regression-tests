#!/bin/bash

echo line written at $(date) >> valid_script.temp 2> /dev/null
wc -l valid_script.temp
