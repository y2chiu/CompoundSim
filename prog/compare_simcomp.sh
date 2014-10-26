#!/usr/bin/env bash
usage="\nUSAGE: $0 DIR_SET1 DIR_SET2 OUT_FILE_NAME\n"

if [ $# -ne 3 ] ; then
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
    export PROG_SIMCOMP=$WDIR"/tools/simcomp"
    export RID=$RANDOM
    
    USER=$(whoami)
    #UTMP="/utmp/${USER}/"
    UTMP="utmp"

    if [ ! -d $UTMP ]; then
        UTMP="utmp"
        mkdir -p $UTMP
    fi  

    UTMP=$(readlink -f $UTMP)


    dset1=$(readlink -f $1)
    dset2=$(readlink -f $2)
    fout=$3
    
    set1=$(echo $dset1 | xargs -I{} basename {} "/")
    set2=$(echo $dset2 | xargs -I{} basename {} "/")

    dkcf1="$dset1/3_kcf/"
    dkcf2="$dset2/3_kcf/"
    fkcf1="$dset1/path.$set1.kcf"
    fkcf2="$dset2/path.$set2.kcf"
    
    if [ ! -d $dkcf1 ] ; then
        echo " !! [ERROR] DIR_KCF1: ${dkcf1} doesn't exist"
        exit 1;
    elif [ ! -d $dkcf2 ] ; then
        echo " !! [ERROR] DIR_KCF2: ${dkcf2} doesn't exist"
        exit 1;
    fi
        
    if [ ! -f $fkcf1 ]; then
        #echo " !! [ERROR] NO SET1 KCF PATH_FILE: ${fkcf1}" 
        find $dkcf1 -name '*.kcf' | sort > $fkcf1
    fi
    if [ ! -f $fkcf2 ]; then
        #echo " !! [ERROR] NO SET2 KCF PATH_FILE: ${fkcf2}" 
        find $dkcf2 -name '*.kcf' | sort > $fkcf2
    fi

    fout1=${fout}.simcomp_global.out
    fout2=${fout}.simcomp_local.out
    scr1="$UTMP/t5_align_kcf_$RID.global.script";
    scr2="$UTMP/t5_align_kcf_$RID.local.script";

    echo "#1 calculate GLOBAL simcomp"
    php $WDIR/5_simcomp.php $PROG_SIMCOMP "global" $fkcf1 $fkcf2 > $scr1
    echo "  script: $scr1"
    #sh $scr1 | cut -f 1,3,6 > $fout1
    sh $scr1 | awk '{printf("%s|%s\t%s\n",$1,$3,$6);}' > $fout1 

    echo "#2 calculate LOCAL simcomp"
    php $WDIR/5_simcomp.php $PROG_SIMCOMP "local" $fkcf1 $fkcf2 > $scr2
    echo "  script: $scr2"
    #sh $scr2 | cut -f 1,3,6 > $fout2 
    sh $scr2 | awk '{printf("%s|%s\t%s\n",$1,$3,$6);}' > $fout2 
    
    echo "#3 merge results"
    fout3=${fout}.simcomp_result.txt

    #paste $fout1 $fout2 | cut -f 1-3,6 > $fout3
    paste $fout1 $fout2 | cut -f 1-2,4 | awk 'BEGIN{FS="[ |\t]";OFS="\t";}{NF=NF; print $0}' > $fout3

    sed -i "1i #Compound1\tCompound2\tSIMCOMP_global\tSIMCOMP_local" $fout3
    
    echo "#4 done !!";
    echo "  result: $fout3";
fi
