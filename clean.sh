#!/bin/sh
ROOTDIR=`/bin/pwd`
for dir in `find . -type d -print`
do
    if [ -f ${dir}/Makefile ]; then
        make -C "${dir}" clean
    fi  
done
