#!/usr/bin/env bash
usage="USAGE: $0 DIR_KCF1 DIR_KCF2 DIR_ALIGN_TYPE"

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
elif [ $3 != "global" ] && [ $3 != "local" ] ; then
    echo " !! [ERROR] WRONG ALIGN TYPES"
    echo ${usage}
    exit 1
else
    if [ -z $WDIR ]; then
        WDIR=$(dirname $(readlink -f $0));
        # for shell without readlink 
        #WDIR=$(cd "$(dirname "$0")" && pwd -P);
    fi
    
    if [ -z $PROG_SIMCOMP ]; then
        #echo " !! [ERROR] Lost simcomp program path"
        #echo " COMMAND: export PROG_SIMCOMP=[PATH of SIMCOMP]"
        #exit 1
        PROG_SIMCOMP="$WDIR/tools/simcomp"
    fi

    if [ -z $RID ]; then
        RID=$RANDOM
    fi

    dkcf1=$(readlink -f $1)
    dkcf2=$(readlink -f $2)
    alnt=$3

    USER=$(whoami)
    UTMP="/utmp/${USER}/"

    if [ ! -d $UTMP ]; then
        UTMP="utmp"
        mkdir -p $UTMP
    fi  

    UTMP=$(readlink -f $UTMP)
    
    fout="$UTMP/t5_align_kcf_$RID.$alnt.script";
    #lst1=$(find $dkcf1 -name '*.kcf' -exec basename {} ".kcf" \; | sort)
    #lst2=$(find $dkcf2 -name '*.kcf' -exec basename {} ".kcf" \; | sort)
    lst1=$(find $dkcf1/ -name '*.kcf' | sort)
    lst2=$(find $dkcf2/ -name '*.kcf' | sort)

    echo -n "" > $fout
    for i in $lst1
    do
        for j in $lst2
        do
            echo "$PROG_SIMCOMP -m k_to_k --$alnt $i $j" >> $fout
        done
    done

    echo $fout
    #sh $fout
fi
