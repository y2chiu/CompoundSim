#!/usr/bin/env bash
usage="USAGE: $0 DIR_SET1 DIR_SET2 OUT_FILE_NAME"

if [ $# -ne 3 ] ; then
    echo " !! [ERROR] Missing arguments!!"
    echo ${usage}
    exit 1
elif [ ! -d $1 ] ; then
    echo " !! [ERROR] DIR_SET1: ${1} doesn't exist"
    echo ${usage}
    exit 1
elif [ ! -d $2 ] ; then
    echo " !! [ERROR] DIR_SET2: ${2} doesn't exist"
    echo ${usage}
    exit 1
elif [ -z $3 ] ; then
    echo ${usage}
    exit 1
else
    W=$(dirname $(readlink -f $0));
    # for shell without readlink 
    #W=$(cd "$(dirname "$0")" && pwd -P);
    export WDIR=$W
    #export PROG_TIMEOUT="timeout"
    export PROG_TIMEOUT=$WDIR"/scripts/timeout -t "
    export PROG_SIMCOMP=$WDIR"/tools/simcomp"
    export RID=$RANDOM

    dset1=$(readlink -f $1)
    dset2=$(readlink -f $2)
    fout=$3
    
    set1=$(echo $dset1 | xargs -I{} basename {} "/")
    set2=$(echo $dset2 | xargs -I{} basename {} "/")

    fea1_ap=$dset1"/fea.ap."$set1
    fea1_cm=$dset1"/fea.cm."$set1
    dkcf1=$dset1"/3_kcf"
    
    if [ ! -f $fea1_ap ]; then
        echo " !! [ERROR] NO SET1 AP FEATURE FILE: ${fea1_ap}" 
        exit 1
    elif [ ! -f $fea1_cm ]; then
        echo " !! [ERROR] NO SET1 CM FEATURE FILE: ${fea1_cm}" 
        exit 1
    elif [ ! -d $dkcf1 ]; then
        echo " !! [ERROR] SET1 KCF DIR doesn't exist: ${dkcf1}" 
        exit 1
    fi
    
    fea2_ap=$dset2"/fea.ap."$set2
    fea2_cm=$dset2"/fea.cm."$set2
    dkcf2=$dset2"/3_kcf"
    
    if [ ! -f $fea2_ap ]; then
        echo " !! [ERROR] NO SET1 AP FEATURE FILE: ${fea2_ap}" 
        exit 1
    elif [ ! -f $fea2_cm ]; then
        echo " !! [ERROR] NO SET1 CM FEATURE FILE: ${fea2_cm}" 
        exit 1
    elif [ ! -d $dkcf2 ]; then
        echo " !! [ERROR] SET1 KCF DIR doesn't exist: ${dkcf2}" 
        exit 1
    fi

    echo -e "\n#A. RUN FEATURE COMPARISON"
    sh $WDIR/compare_fea.sh $fea1_ap $fea2_ap $fout
    
    echo -e "\n#B. RUN GLOBAL/LOCAL SIMCOMP"
    sh $WDIR/compare_blade_simcomp.sh $dkcf1 $dkcf2 $fout
    
    echo -e "\n#C. RUN JOBS AND MERGE RESULTS\n"
    echo -e "  run towork.sh to submit jobs"
    echo -e "  run tomerge.sh to merge all results when jobs finished\n"
fi
