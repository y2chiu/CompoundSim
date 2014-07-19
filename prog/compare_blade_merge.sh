#!/usr/bin/env bash
usage="USAGE: $0 DIR_GOUT DIR_LOUT OUT_FILE_NAME"

if [ $# -ne 3 ] ; then
    echo " !! [ERROR] Missing arguments!!"
    echo ${usage}
    exit 1
elif [ ! -d $1 ] ; then
    echo " !! [ERROR] DIR_GOUT: ${1} doesn't exist"
    echo ${usage}
    exit 1
elif [ ! -d $2 ] ; then
    echo " !! [ERROR] DIR_LOUT: ${2} doesn't exist"
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

    dgout=$(readlink -f $1)
    dlout=$(readlink -f $2)
    fout=$3
    fout1=${fout}.simcomp_global.out
    fout2=${fout}.simcomp_local.out
    fout3=${fout}.simcomp_result.txt
    fout4=${fout}.simcomp_result.sorted.txt

    echo "#1 merge simcomp results"
    cat `find $dgout -type f -name 'job*.o*' | sort` | cut -f 1,3,6 > $fout1
    cat `find $dlout -type f -name 'job*.o*' | sort` | cut -f 1,3,6 > $fout2
    
    paste $fout1 $fout2 | cut -f 1-3,6 > $fout3
    cat $fout3 | grep "^#" -v | sort -nrk 3 -nrk 4 > $fout4

    sed -i "1i #Compound1\tCompound2\tSIMCOMP_global\tSIMCOMP_local" $fout3
    sed -i "1i #Compound1\tCompound2\tSIMCOMP_global\tSIMCOMP_local" $fout4
    
    echo "  result: $fout3";
    echo "  sorted: $fout4";


    echo "#2 merge all results";

    f1=${fout}.fea_tani_ap.txt
    f2=${fout}.fea_tani_cm.txt
    f3=${fout}.simcomp_global.out
    f4=${fout}.simcomp_local.out
    fo=${fout}_result.txt
    php $WDIR/6_merge_result.php $f1 $f2 $f3 $f4 > $fo

    sed -i "1i #Compound1\tCompound2\tAP_tanimoto\tCheckmol_tanimoto\t\tSIMCOMP_global\tSIMCOMP_local" $fo

    echo "#3 Done !!"
    echo "  result: $fo"
fi
