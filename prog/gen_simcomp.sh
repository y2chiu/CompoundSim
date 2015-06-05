#!/usr/bin/env bash
usage="USAGE: $0 DIR_MOL"

if [ -z $1 ] || [ ! -d $1 ] || [ $# -ne 1 ]; then
    echo " !! [ERROR] Missing arguments!!"
    echo ${usage}
    exit 1
else
    
    W=$(dirname $(readlink -f $0));
    export WDIR=$W

    if [ -z "$PROG_TIMEOUT" ]; then
        export PROG_TIMEOUT=$WDIR"/scripts/timeout -t "
    fi
    if [ -z "$PROG_KCF"     ]; then 
        export PROG_KCF=$WDIR"/tools/makekcf"
    fi
    if [ -z "$PROG_SIMCOMP" ]; then
        export PROG_SIMCOMP=$WDIR"/tools/simcomp"
    fi
    if [ -z "$RID"          ]; then
        export RID=$RANDOM
    fi


    dmol=$(readlink -f $1)
    dout=$dmol

    dlog=$dout"/.log"
    dkcf=$dout"/kcf"

    mkdir -p $dlog
    mkdir -p $dkcf

    name=$(echo $dmol | xargs -I{} basename {} "/")
    if [ -z $name ]; then
        name="query"
    fi
    export SET_NAME=$name
    dkcf=$(readlink -f $dkcf)

    echo "#1 translate to KCF: $dkcf"

    fout="${dlog}/t3_trans_kcf_$RID.script"
    flog="${dlog}/t3_trans_kcf_$RID.log"

    find $dmol/ -type f -name '*.mol' -printf '%h|%f\n' | sed 's/\.mol//' | \
        awk -F"|" -v s="$PROG_TIMEOUT" -v p="$PROG_KCF" -v dkcf="$dkcf" \
        '{ printf("%s 60 %s -name %s %s/%s.mol %s/%s.kcf\n",s,p,$2,$1,$2,dkcf,$2);}' \
        > $fout
    echo "  script: $fout"
    n=$(cat $fout | wc -l)
    echo "  total $n MOL files"

    if [ -z "$BLADE_MODE" ]; then
        sh $fout > $flog 2>&1

        fout="path.$SET_NAME.kcf"
        find $dkcf -type f -name '*.kcf' > $dout/$fout

        n=$(cat $dout/$fout | wc -l)
        echo "  generate $n KCF files"
    
        echo -e "\n#2 done !!";
    else
        jdout="$DJOB/job${RID}.tokcf"
        jscr=$fout
    
        mkdir -p $jdout
        cd $jdout;
        sh $PROG_TOJOB $jscr 50 towork_kcf.sh 1
        cd $CDIR;
    
        cat >> $BLADE_SCRIPT <<EOF
cd $jdout;
sh towork_kcf.sh;
cd $CDIR
EOF
        echo "  run the script: $BLADE_SCRIPT"
    fi
fi
