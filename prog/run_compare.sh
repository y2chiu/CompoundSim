#!/usr/bin/env bash
usage="\nUSAGE: $0 DIR_SET1 DIR_SET2 OUT_FILE_NAME [TH_AP [TH_CM]]\n"
    
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

if [ $# -lt 3 ] || [ $# -gt 5 ]; then
    echo " !! [ERROR] Missing arguments!!"
    echo -e ${usage}
    exit 1
elif [ ! -d $1 ] ; then
    echo " !! [ERROR] DIR_SET1: ${1} doesn't exist"
    echo -e ${usage}
    exit 1
elif [ ! -d $2 ] ; then
    echo -e " !! [ERROR] DIR_SET2: ${2} doesn't exist"
    echo -e ${usage}
    exit 1
elif [ -z $3 ] ; then
    echo -e ${usage}
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
        export ALL_MODE="1"

        # clear BLADE_SCRIPT file
        echo "" > $BLADE_SCRIPT
    fi

    dset1=$(readlink -f $1)
    dset2=$(readlink -f $2)
    fout=$3
    th_ap=0.5
    th_cm=0.5

    if [ ! -z $5 ] ; then
        th_ap=$4
        th_cm=$5
    elif [ ! -z $4 ] ; then
        th_ap=$4
        th_cm=$4
    fi


    echo -e "\n#A. RUN FEATURE COMPARISON"
    sh $WDIR/compare_fea.sh $dset1 $dset2 $fout $th_ap $th_cm
    
    echo -e "\n#B. RUN GLOBAL/LOCAL SIMCOMP"
    sh $WDIR/compare_simcomp.sh $dset1 $dset2 $fout
    
    if [ -z "$BLADE_MODE" ]; then
        f1=${fout}.fea_tani_ap.txt
        f2=${fout}.fea_tani_cm.txt
        f3=${fout}.simcomp_global.out
        f4=${fout}.simcomp_local.out
        fo=${fout}_compare_result.txt

        php $WDIR/merge_result.php $f1 $f2 $f3 $f4 | awk 'BEGIN{FS="[ |\t]";OFS="\t";}{NF=NF; print $0}' > $fo
        sed -i "1i #Compound1\tCompound2\tAP_tanimoto\tCheckmol_tanimoto\t\tSIMCOMP_global\tSIMCOMP_local" $fo

        echo -e "\n#C. DONE"
        echo -e "  result: \033[1;33m${fo}\033[m"
        echo
        
    else
        echo -e "\n#C. RUN JOBS AND MERGE RESULTS"
        echo -e "  \033[1;31mrun towork_all.sh to submit jobs\033[m"
        echo -e "  \033[1;31mrun tomerge_all.sh to merge all results when jobs finished\033[m"
        echo
    
        f1=${fout}.fea_tani_ap.txt
        f2=${fout}.fea_tani_cm.txt
        f3=${fout}.simcomp_global.out
        f4=${fout}.simcomp_local.out
        fo=${fout}_compare_result.txt
    
        cat > towork_all.sh <<EOF
sh towork_simcomp.sh;
sh towork_fea.sh;
EOF
        cat > tomerge_all.sh <<EOF 
sh tomerge_fea.sh;
sh tomerge_simcomp.sh;
php $WDIR/merge_result.php $f1 $f2 $f3 $f4 | awk 'BEGIN{FS="[ |\t]";OFS="\t";}{NF=NF; print \$0}' > $fo
sed -i "1i #Compound1\tCompound2\tAP_tanimoto\tCheckmol_tanimoto\t\tSIMCOMP_global\tSIMCOMP_local" $fo
echo -e "#done"
echo -e "  result: \033[1;33m$fo\033[m"
EOF
        chmod +x towork_all.sh tomerge_all.sh
    fi
fi
