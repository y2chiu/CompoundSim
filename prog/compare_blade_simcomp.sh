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
    export PROG_TOJOB=$WDIR"/scripts/tojob.sh"
    export RID=$RANDOM
    
    USER=$(whoami)
    UTMP="/utmp/${USER}/"

    if [ ! -d $UTMP ]; then
        UTMP="utmp"
        mkdir -p $UTMP
    fi  

    UTMP=$(readlink -f $UTMP)
    CDIR=$(readlink -f $PWD)

    dkcf1=$(readlink -f $1)
    dkcf2=$(readlink -f $2)
    fout=$3
    dout1=$UTMP/${fout}.simcomp_global.job
    dout2=$UTMP/${fout}.simcomp_local.job
    fout1=${fout}.simcomp_global.out
    fout2=${fout}.simcomp_local.out

    echo "#1 calculate GLOBAL simcomp"
    scr1=$(sh $WDIR/5_simcomp.sh $dkcf1 $dkcf2 "global")
    echo "  generate simcomp script: $scr1"

    mkdir -p $dout1
    cd $dout1;
    sh $PROG_TOJOB $scr1 25 toworkG.sh
    cd $CDIR;
    
    echo "#2 calculate LOCAL simcomp"
    scr2=$(sh $WDIR/5_simcomp.sh $dkcf1 $dkcf2 "local")
    echo "  generate simcomp script: $scr2"

    mkdir -p $dout2
    cd $dout2;
    sh $PROG_TOJOB $scr2 25 toworkL.sh
    cd $CDIR;

    
    echo "#3 generate qsub script: towork.sh"
    echo "  simcomp global: $dout1";
    echo "  simcomp local : $dout2";

    echo -e "cd $dout1;sh toworkG.sh;cd -;\ncd $dout2;sh toworkL.sh;cd -;\n" > towork.sh
    echo "sh $WDIR/compare_blade_merge.sh $dout1 $dout2 $fout" > tomerge.sh
    chmod +x towork.sh tomerge.sh

fi
