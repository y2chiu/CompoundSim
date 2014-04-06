#!/usr/bin/env bash
usage="USAGE: $0 FEA_SET1 FEA_SET2 OUT_FILE_NAME"

if [ $# -ne 3 ] ; then
    echo " !! [ERROR] Missing arguments!!"
    echo ${usage}
    exit 1
elif [ ! -f $1 ] ; then
    echo " !! [ERROR] FEA_SET1: ${1} doesn't exist"
    echo ${usage}
    exit 1
elif [ ! -f $2 ] ; then
    echo " !! [ERROR] FEA_SET2: ${2} doesn't exist"
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

    fea_ap1=$(readlink -f $1)
    fea_ap2=$(readlink -f $2)
    fout=$3
    
    dfea1=$(dirname $fea_ap1)
    dfea2=$(dirname $fea_ap2)
    fea_cm1=$dfea1/$(basename $fea_ap1 | sed 's/ap/cm/g')
    fea_cm2=$dfea2/$(basename $fea_ap2 | sed 's/ap/cm/g')

    echo "#1 calculate tanimoto similarity"
    fout_ap=$fout.fea_tani_ap.txt
    fout_cm=$fout.fea_tani_cm.txt
    php $WDIR/4_tanimoto_pair.php $fea_ap1 $fea_ap2 > $fout_ap
    php $WDIR/4_tanimoto_pair.php $fea_cm1 $fea_cm2 > $fout_cm

    echo "#2 merge results"
    fout3=${fout}.fea_result.txt
    fout4=${fout}.fea_result.sorted.txt

    paste $fout_ap $fout_cm | cut -f 1-3,6 > $fout3
    cat $fout3 | grep "^#" -v | sort -nrk 3 -nrk 4 > $fout4

    sed -i "1i #Compound1\tCompound2\tAP_tanimoto\tCheckmol_tanimoto" $fout3
    sed -i "1i #Compound1\tCompound2\tAP_tanimoto\tCheckmol_tanimoto" $fout4
    
    echo "#3 done !!";
    echo "  result: $fout3";
    echo "  sorted: $fout4";
fi
