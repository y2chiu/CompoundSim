#!/usr/bin/env bash
usage="\nUSAGE: $0 DIR_SET1 DIR_SET2 OUT_FILE_NAME [TH_AP [TH_CM]]\n"

if [ $# -lt 3 ] || [ $# -gt 5 ]; then
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
    th_ap=0.5
    th_cm=0.5
    
    if [ ! -z $5 ] ; then
        th_ap=$4
        th_cm=$5
    elif [ ! -z $4 ] ; then
        th_ap=$4
        th_cm=$4
    fi 
    
    set1=$(echo $dset1 | xargs -I{} basename {} "/")
    set2=$(echo $dset2 | xargs -I{} basename {} "/")

    fea1_ap=$dset1"/fea.ap."$set1
    fea1_cm=$dset1"/fea.cm."$set1
    
    if [ ! -f $fea1_ap ]; then
        echo " !! [ERROR] NO SET1 AP FEATURE FILE: ${fea1_ap}" 
        exit 1
    elif [ ! -f $fea1_cm ]; then
        echo " !! [ERROR] NO SET1 CM FEATURE FILE: ${fea1_cm}" 
        exit 1
    fi
    
    fea2_ap=$dset2"/fea.ap."$set2
    fea2_cm=$dset2"/fea.cm."$set2
    
    if [ ! -f $fea2_ap ]; then
        echo " !! [ERROR] NO SET2 AP FEATURE FILE: ${fea2_ap}" 
        exit 1
    elif [ ! -f $fea2_cm ]; then
        echo " !! [ERROR] NO SET2 CM FEATURE FILE: ${fea2_cm}" 
        exit 1
    fi

    echo 
    echo "#[THRESHOLD] AP: ${th_ap}, CM: ${th_cm}"
    echo 
    echo "#1 calculate tanimoto similarity"
    fout_ap=$fout.fea_tani_ap.txt
    fout_cm=$fout.fea_tani_cm.txt
    php $WDIR/4_tanimoto_pair.php $fea1_ap $fea2_ap $th_ap > $fout_ap
    php $WDIR/4_tanimoto_pair.php $fea1_cm $fea2_cm $th_cm > $fout_cm

    echo "#2 merge results"
    fout3=${fout}.fea_result.txt

    #BUG: lost something
    #join $fout_ap $fout_cm | awk 'BEGIN{FS="[ |\t]";OFS="\t";}{NF=NF; print $0}' > $fout3
    php $WDIR/merge_result.php $fout_ap $fout_cm | awk 'BEGIN{FS="[ |\t]";OFS="\t";}{NF=NF; print $0}' > $fout3

    sed -i "1i #Compound1\tCompound2\tAP_tanimoto\tCheckmol_tanimoto" $fout3
    
    echo "#3 done !!";
    echo "  result: $fout3";
fi
