#!/usr/bin/env bash
usage="\nUSAGE: $0 DIR_MOL\n"
    
while getopts "b" opt; do
    case $opt in
    b)
        export BLADE_MODE="1"
        ;;

    \?)
        echo "Invalid option: -$OPTARG" >&2
        ;;
    esac
done
shift $((OPTIND-1))

if [ -z $1 ] || [ ! -d $1 ] || [ $# -ne 1 ]; then
    echo " !! [ERROR] Missing arguments!!"
    echo ${usage}
    exit 1
else

    # for shell without readlink 
    #W=$(cd "$(dirname "$0")" && pwd -P);
    W=$(dirname $(readlink -f $0));
    export WDIR=$W

    #export PROG_TIMEOUT="timeout"
    #export PROG_BABEL="babel"
    if [ -z "$PROG_TIMEOUT" ]; then
        export PROG_TIMEOUT=$WDIR"/scripts/timeout -t "
    fi
    if [ -z "$PROG_BABEL"   ]; then 
        export PROG_BABEL=$WDIR"/tools/babel"
    fi
    if [ -z "$PROG_AP"      ]; then
        export PROG_AP=$WDIR"/tools/ap"
    fi
    if [ -z "$PROG_APDEF"   ]; then
        export PROG_APDEF=$WDIR"/tools/ap_DEFINITION.txt"
    fi
    if [ -z "$PROG_CM"      ]; then
        export PROG_CM=$WDIR"/tools/checkmol"
    fi
    if [ -z "$RID"          ]; then
        export RID=$RANDOM
    fi


    if [ ! -z "$BLADE_MODE" ]; then 
        echo "#[USING BLADE MODE]"
            
        DJOB="tojob"
        mkdir -p $DJOB

        export PROG_TOJOB=$WDIR"/scripts/tojob.sh"
        export BLADE_SCRIPT="towork.sh"
        export DJOB=$(readlink -f $DJOB)
        export CDIR=$(readlink -f $PWD)

        # clear BLADE_SCRIPT file
        echo "" > $BLADE_SCRIPT
    fi

    dmol=$(readlink -f $1)

    ### AP
    echo -e "\n#A. GENERATE AP FEATURES"
    sh $WDIR/gen_ap_fea.sh $dmol

    ### Checkmol
    echo -e "\n#B. GENERATE CHECKMOL FEATURES"
    sh $WDIR/gen_cm_fea.sh $dmol

    echo -e "\n#C. DONE";
fi
