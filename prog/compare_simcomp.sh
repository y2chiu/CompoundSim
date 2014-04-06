#!/usr/bin/env bash
usage="USAGE: $0 DIR_KCF1 DIR_KCF2 OUT_FILE_NAME"

if [ $# -ne 3 ] ; then
    echo " !! [ERROR] Missing arguments!!"
    echo ${usage}
    exit 1
elif [ ! -d $1 ] ; then
    echo " !! [ERROR] DIR_KCF1: ${1} doesn't exist"
    echo ${usage}
    exit 1
elif [ ! -d $2 ] ; then
    echo " !! [ERROR] DIR_KCF2: ${2} doesn't exist"
    echo ${usage}
    exit 1
elif [ -z $3 ] ; then
    echo ${usage}
    exit 1
else
    W=$(dirname $(readlink -f $0))
    # for shell without readlink 
    #W=$(cd "$(dirname "$0")" && pwd -P)
    export WDIR=$W
    export PROG_SIMCOMP=$WDIR"/tools/simcomp"
    export RID=$RANDOM

    dkcf1=$(readlink -f $1)
    dkcf2=$(readlink -f $2)
    fout=$3
    fout1=${fout}_global.out
    fout2=${fout}_local.out

    echo "#1 calculate GLOBAL simcomp"
    scr1=$(sh $WDIR/5_simcomp.sh $dkcf1 $dkcf2 "global")
    echo "  script: $scr1"
    sh $scr1 > $fout1 

    echo "#2 calculate LOCAL simcomp"
    scr2=$(sh $WDIR/5_simcomp.sh $dkcf1 $dkcf2 "local")
    echo "  script: $scr2"
    sh $scr2 > $fout2 
    echo "#3 merge results"
    fout3=${fout}_result.txt
    fout4=${fout}_result.sorted..txt

    paste $fout1 $fout2 | cut -f 1,3,6,13 > $fout3
    cat $fout3 | grep "^#" -v | sort -nrk 3 -nrk 4 > $fout4

    sed -i "1i #Compound1\tCompound2\tSIMCOMP_global\tSIMCOMP_local" $fout3
    sed -i "1i #Compound1\tCompound2\tSIMCOMP_global\tSIMCOMP_local" $fout4
    
    echo "#4 done !!";
fi
