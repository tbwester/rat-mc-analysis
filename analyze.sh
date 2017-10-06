#!/bin/bash

FILES=`find data/ -name '*.tar.gz'`

for line in $FILES; do 
    echo "${line%.tar.gz}"/PESpec.root >> filelist.txt
    if [ ! -d "${line%.tar.gz}" ]; then
        mkdir -p "${line%.tar.gz}"
        tar -xf "$line" -C "${line%.tar.gz}"
    fi
done

root -l 'peakfit.cc("filelist.txt")'

rm filelist.txt

Rscript r/param_analyze.R
