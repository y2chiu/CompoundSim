#!/usr/bin/env bash
usage="\nUSAGE: $0 DIR_SET1 DIR_SET2 OUT_FILE_NAME [TH_CM]\n"

if [ $# -lt 3 ] || [ $# -gt 4 ]; then
    echo " !! [ERROR] Missing arguments!!"
    echo -e ${usage}
    exit 1
elif [ ! -d $1 ] ; then
    echo " !! [ERROR] DIR_SET1: ${1} doesn't exist"
    echo -e ${usage}
    exit 1
elif [ ! -d $2 ] ; then
    echo " !! [ERROR] DIR_SET2: ${2} doesn't exist"
    echo -e ${usage}
    exit 1
elif [ -z $3 ] ; then
    echo -e ${usage}
    exit 1
else
    W=$(dirname $(readlink -f $0))
    # for shell without readlink 
    #W=$(cd "$(dirname "$0")" && pwd -P)
    export WDIR=$W

    dset1=$(readlink -f $1)
    dset2=$(readlink -f $2)
    fout=$3
    th_cm=0.5
    
    if [ ! -z $4 ] ; then
        th_cm=$4
    fi 
    
    set1=$(echo $dset1 | xargs -I{} basename {} "/")
    set2=$(echo $dset2 | xargs -I{} basename {} "/")

    fea1_cm=$dset1"/fea/fea.cm."$set1
    
    if [ ! -f $fea1_cm ]; then
        echo " !! [ERROR] NO SET1 CM FEATURE FILE: ${fea1_cm}" 
        exit 1
    fi
    
    fea2_cm=$dset2"/fea/fea.cm."$set2
    
    if [ ! -f $fea2_cm ]; then
        echo " !! [ERROR] NO SET2 CM FEATURE FILE: ${fea2_cm}" 
        exit 1
    fi

    echo 
    echo "#[THRESHOLD] CM: ${th_cm}"
    echo 
    echo "#1 calculate tanimoto similarity"
    fout_cm=$fout.fea_tani_cm.txt
    php $WDIR/4_tanimoto_pair.php $fea1_cm $fea2_cm $th_cm \
        | awk 'BEGIN{FS="[ |\t]";OFS="\t";}{NF=NF; print $0}' > $fout_cm

    sed -i "1i #Compound1\tCompound2\tCheckmol_tanimoto" $fout_cm
    
    echo "#3 done !!";
    echo "  result: $fout_cm";
fi
