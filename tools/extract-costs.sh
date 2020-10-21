#!/bin/bash
grep -a "Cost [-e0-9.]\+ " | sed -r "s/.* Cost ([-e0-9.]+) .*: Time.*/\\1/"
