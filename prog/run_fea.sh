#!/usr/bin/env bash
usage="USAGE: $0 DIR_MOL"

if [ -z $1 ] || [ ! -d $1 ] || [ $# -ne 1 ]; then
    echo " !! [ERROR] Missing arguments!!"
    echo ${usage}
    exit 1
else
    W=$(dirname $(readlink -f $0));
    # for shell without readlink 
    #W=$(cd "$(dirname "$0")" && pwd -P);
    export WDIR=$W
    #export PROG_TIMEOUT="timeout"
    export PROG_TIMEOUT=$WDIR"/scripts/timeout -t "
    #export PROG_BABEL="babel"
    export PROG_BABEL=$WDIR"/tools/babel"
    export PROG_AP=$WDIR"/tools/ap"
    export PROG_APDEF=$WDIR"/tools/ap_DEFINITION.txt"
    export PROG_CM=$WDIR"/tools/checkmol"
    export PROG_KCF=$WDIR"/tools/makekcf"
    export PROG_SIMCOMP=$WDIR"/tools/simcomp"
    export RID=$RANDOM

    dmol=$1
    dmol2=$(echo $dmol | sed 's/1_mol/2_mol2/');
    dkcf=$(echo $dmol | sed 's/1_mol/3_kcf/');

    name=$(echo $dmol | sed 's/1_mol//' | xargs -I{} basename {} "/")
    if [ -z $name ]; then
        name="query"
    fi
    export SET_NAME=$name

    mkdir -p $dmol2;
    mkdir -p $dkcf;

    dout=$(dirname $dmol);
    find $dmol/ -name '*.mol' > $dout/list.$SET_NAME.txt
    n=$(cat $dout/list.$SET_NAME.txt | wc -l)
    echo "#1 There are $n MOL files";
    
    echo "#2 translate to MOL2: $dmol2";
    sh $WDIR/1_trans_mol2.sh $dmol $dmol2
    n=$(find $dmol2 -type f -name '*.mol2' | wc -l)
    echo "  generate $n MOL2 files"
    
    echo "#3 generate compound features";
    sh $WDIR/2_gen_fea.sh $dmol $dmol2

    echo "#4 translate to KCF: $dkcf"
    sh $WDIR/3_mol2kcf.sh $dmol $dkcf

    d=$(readlink -f $dkcf)
    o="path.$name.kcf"
    find $d -type f -name '*.kcf' > $dout/$o

    n=$(cat $o | wc -l)
    echo "  generate $n KCF files"
    
    echo "#5 done !!";
fi
