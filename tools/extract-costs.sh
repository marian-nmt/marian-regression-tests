#!/bin/bash
grep "Cost [-e0-9.]\+ " | sed -r "s/.* Cost ([-e0-9.]+) : Time.*/\\1/"
