#!/bin/bash

FILES=`find data/ -name '*.tar.gz'`

for line in $FILES; do 
    echo "${line%.tar.gz}"/PESpec.root >> filelist.txt
    mkdir -p "${line%.tar.gz}" 
    tar -xf "$line" -C "${line%.tar.gz}"
done

root -l 'peakfit.cc("filelist.txt")'

rm filelist.txt
