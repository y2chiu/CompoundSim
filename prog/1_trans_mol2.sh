#!/usr/bin/env bash
usage="USAGE: $0 DIR_MOL DIR_MOL2"

if [ $# -ne 2 ] ; then
    echo " !! [ERROR] Missing arguments!!"
    echo ${usage}
    exit 1
elif [ ! -d $1 ] ; then
    echo " !! [ERROR] DIR_MOL: ${1} doesn't exist"
    echo ${usage}
    exit 1
elif [ ! -d $2 ] ; then
    echo " !! [ERROR] DIR_MOL2: ${2} doesn't exist"
    echo ${usage}
    exit 1
else 
    dlog=$(dirname $1)"/.log"
    fout="${dlog}/t1_trans_mol2_$RID.script"
    flog="${dlog}/t1_trans_mol2_$RID.log"
   
    mkdir -p $dlog
    find $1/ -name '*.mol' -exec basename {} '.mol' \; | \
        xargs -I{} echo "$PROG_TIMEOUT 60 $PROG_BABEL -d -i mol $1/{}.mol -o mol2 $2/{}.mol2" > $fout
    
    echo "  script: $fout"
    sh $fout >$flog 2>&1
fi
