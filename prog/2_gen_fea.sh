#!/usr/bin/env bash
usage="USAGE: $0 DIR_MOL DIR_MOL2 [DIR_FEA]"

if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo " !! [ERROR] Missing arguments!!"
    echo ${usage}
    exit 1
elif [ ! -d $1 ] ; then
    echo " !! [ERROR] DIR_MOL: ${1} doesn't exist"
    echo ${usage}
    exit 1
elif [ ! -d $2 ] ; then
    echo " !! [ERROR] DIR_MOL2: ${2} doesn't exist"
    echo ${usage}
    exit 1
elif [ ! -d $3 ] ; then
    echo " !! [ERROR] DIR_FEA: ${3} doesn't exist"
    echo ${usage}
    exit 1
else

    dout=$(dirname $1)
    dlog=$(dirname $1)"/.log"
    dmol=$1
    dmol2=$2
    dfea=$dout

    mkdir -p $dlog
    if [ $# -eq 3 ]; then
        dfea=$3
        mkdir -p $dfea
    fi

    ### Checkmol
    fout="${dlog}/t2_get_fea_cm_$RID.cript";
    find $dmol -type f -name '*.mol' -exec basename {} ".mol" \; | \
        awk -v P=$PROG_CM -v dmol=$dmol \
        '{printf("echo -n \"%s\t\";%s -s %s/%s.mol\n",$1,P,dmol,$1);}' > $fout
    bash $fout | sort > $dfea/fea.cm.$SET_NAME

    ### AP
    find $dmol2 -type f -name '*.mol2' > $dlog/lst.ap.$SET_NAME.txt
    if [ ! -f "ap_DEFINITION.txt" ]; then
        cp -r $PROG_APDEF .
    fi;
    $PROG_AP $dlog/lst.ap.$SET_NAME.txt
    php $WDIR/9_transFea.php $dlog/lst.ap.$SET_NAME-ap.txt | sort > $dfea/fea.ap.$SET_NAME
fi
