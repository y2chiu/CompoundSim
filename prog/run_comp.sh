#!/usr/bin/env bash
usage="USAGE: $0 DIR_SET1 DIR_SET2"

if [ $# -ne 2 ] || [ ! -d $1 ] || [ ! -d $2 ]; then
    echo " !! [ERROR] Missing arguments!!"
    echo ${usage}
    exit 1
else
    W=$(dirname $(readlink -f $0));
    # for shell without readlink 
    #W=$(cd "$(dirname "$0")" && pwd -P);
    export WDIR=$W
    #export PROG_TIMEOUT="timeout"
    export PROG_TIMEOUT=$WDIR"/tools/timeout -t "
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

    echo "#1 translate to MOL2: $dmol2";
    sh $W/1_trans_mol2.sh $dmol $dmol2
    
    echo "#2 generate compound features";
    sh $W/2_gen_fea.sh $dmol $dmol2

    echo "#3 translate to KCF: $dkcf"
    sh $W/3_mol2kcf.sh $dmol $dkcf
    n=$(find $dkcf -type f -name '*.kcf' | wc -l)
    echo "  generate $n KCF files"
    
    W=$(dirname $(readlink -f $0));
    dfea=$(readlink -f $1);
    s1=$2
    s2=$3

    fout=$(date +%Y%m%d);
    setn="$s1-$s2";

    echo -e "#1 calculate tanimoto";
    php $W/4_tanimoto_pair.php $dfea/fea.ap.$s1 $dfea/fea.ap.$s2 > $fout.tani.ap.$setn
    php $W/4_tanimoto_pair.php $dfea/fea.cm.$s1 $dfea/fea.cm.$s2 > $fout.tani.cm.$setn

    echo -e "#2 merge results";
    paste $fout.tani.ap.$setn $fout.tani.cm.$setn | cut -f 1-3,6 > $fout.result.ap-cm.out.$setn
    cat $fout.result.ap-cm.out.$setn | sort -nrk 3 -nrk 4 > $fout.result.ap-cm.sorted.$setn

    echo -e "#3 done !!";
    
    echo "#4 done !!";
fi
