#!/bin/bash

#FILES=`find ../rat-mc-far/data/ -name '*.tar.gz'`
FILES=`find data/ -name '*.tar.gz'`

for line in $FILES; do 
    echo "${line%.tar.gz}"/PlateEff.root >> filelist.txt
    if [ ! -d "${line%.tar.gz}" ]; then
        mkdir -p "${line%.tar.gz}"
        tar -xf "$line" -C "${line%.tar.gz}"
    fi
done

root -l 'eff.cc("filelist.txt")'
#root -l 'analyze.cc("filelist.txt")'

rm filelist.txt

#Rscript r/param_analyze.R
