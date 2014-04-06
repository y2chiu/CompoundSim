#!/usr/bin/env bash
usage="USAGE: $0 DIR_MOL DIR_OUT"

if [ $# -ne 2 ] ; then
    echo " !! [ERROR] Missing arguments!!"
    echo ${usage}
    exit 1
elif [ ! -d $1 ] ; then
    echo " !! [ERROR] DIR_MOL: ${1} doesn't exist"
    echo ${usage}
    exit 1
else 
    if [ -z $WDIR ]; then
        WDIR=$(dirname $(readlink -f $0));
        # for shell without readlink 
        #WDIR=$(cd "$(dirname "$0")" && pwd -P);
    fi

    if [ -z $PROG_BABEL ]; then
        #echo " !! [ERROR] Lost babel program path"
        #echo " COMMAND: export PROG_BABEL=[PATH of babel]"
        #exit 1
        PROG_BABEL="$WDIR/tools/babel"
    fi
    
    if [ -z $PROG_TIMEOUT ]; then
        #export PROG_TIMEOUT="timeout"
        PROG_TIMEOUT=$WDIR"/tools/timeout -t "
    fi
    
    if [ -z $RID ]; then
        RID=$RANDOM
    fi

    dmol=$1
    dout=$2
    dlog=$(dirname $1)"/.log"
    fout="${dlog}/t8_to_png_$RID.script";
    flog="${dlog}/t8_to_png_$RID.log";
    mkdir -p $dlog
    mkdir -p $dout
   

    find $dmol/ -name '*.mol' -exec basename {} '.mol' \; | \
        xargs -I{} echo "$PROG_TIMEOUT 60 $PROG_BABEL -d -imol $dmol/{}.mol -O $dout/{}.png" > $fout
    
    echo $fout
    sh $fout >$flog 2>&1
fi
