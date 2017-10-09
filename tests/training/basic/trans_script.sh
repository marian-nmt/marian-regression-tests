#!/bin/bash

echo script arguments: $@ >> trans_script.temp 2> /dev/null
wc -l trans_script.temp
