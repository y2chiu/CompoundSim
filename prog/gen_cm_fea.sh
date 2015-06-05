#!/usr/bin/env bash
usage="\nUSAGE: $0 DIR_MOL\n"

if [ $# -ne 1 ] ; then
    echo " !! [ERROR] Missing arguments!!"
    echo -e ${usage}
    exit 1
elif [ ! -d $1 ] ; then
    echo " !! [ERROR] DIR_MOL: ${1} doesn't exist"
    echo -e ${usage}
    exit 1
else
    
    W=$(dirname $(readlink -f $0));
    export WDIR=$W

    if [ -z "$PROG_TIMEOUT" ]; then
        export PROG_TIMEOUT=$WDIR"/scripts/timeout -t "
    fi
    if [ -z "$PROG_BABEL"   ]; then 
        export PROG_BABEL=$WDIR"/tools/babel"
    fi
    if [ -z "$PROG_CM"      ]; then
        export PROG_CM=$WDIR"/tools/checkmol"
    fi
    if [ -z "$RID"          ]; then
        export RID=$RANDOM
    fi


    dmol=$(readlink -f $1)
    dout=$dmol

    dlog=$dout"/.log"
    dfea=$dout"/fea"

    mkdir -p $dlog
    mkdir -p $dfea
   

    ### Checkmol
    name=$(echo $dmol | xargs -I{} basename {} "/")
    if [ -z $name ]; then
        name="query"
    fi
    export SET_NAME=$name

    fout="${dlog}/t2_get_fea_cm_$RID.script";
    find $dmol/ -type f -name '*.mol' -printf '%h|%f\n' | sed 's/\.mol//' | \
        awk -F"|" -v p="$PROG_CM" \
        '{ printf("echo -n \"%s\t\";%s -s %s/%s.mol\n",$2,p,$1,$2);}' \
        > $fout
    echo "  script: $fout"
    bash $fout | sort > $dfea/fea.cm.$SET_NAME
    
    echo -e "\n#2 done !!";
    echo -e "  Checkmol feature file: $dfea/fea.cm.$SET_NAME";
fi
