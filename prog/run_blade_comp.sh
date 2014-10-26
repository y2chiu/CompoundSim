#!/usr/bin/env bash
usage="\nUSAGE: $0 DIR_SET1 DIR_SET2 OUT_FILE_NAME [TH_AP [TH_CM]]\n"

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
    W=$(dirname $(readlink -f $0));
    # for shell without readlink 
    #W=$(cd "$(dirname "$0")" && pwd -P);
    export WDIR=$W
    #export PROG_TIMEOUT="timeout"
    export PROG_TIMEOUT=$WDIR"/scripts/timeout -t "
    export PROG_SIMCOMP=$WDIR"/tools/simcomp"
    export PROG_TOJOB=$WDIR"/scripts/tojob.sh"
    export RID=$RANDOM

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

    echo
    echo "#A. RUN FEATURE COMPARISON"
    echo
    sh $WDIR/blade_compare_fea.sh $dset1 $dset2 $fout $th_ap $th_cm
    
    echo "#B. RUN GLOBAL/LOCAL SIMCOMP"
    echo
    sh $WDIR/blade_compare_simcomp.sh $dset1 $dset2 $fout
    
    echo "#C. RUN JOBS AND MERGE RESULTS"
    echo "  run towork.sh to submit jobs"
    echo "  run tomerge.sh to merge all results when jobs finished"
    echo
    
    f1=${fout}.fea_tani_ap.txt
    f2=${fout}.fea_tani_cm.txt
    f3=${fout}.simcomp_global.out
    f4=${fout}.simcomp_local.out
    fo=${fout}_result.txt
    
    cat > towork.sh <<EOF
sh towork_simcomp.sh;
sh towork_fea.sh;
EOF
    cat > tomerge.sh <<EOF 
sh tomerge_fea.sh;
sh tomerge_simcomp.sh;
php $WDIR/merge_result.php $f1 $f2 $f3 $f4 | awk 'BEGIN{FS="[ |\t]";OFS="\t";}{NF=NF; print \$0}' > $fo
sed -i "1i #Compound1\tCompound2\tAP_tanimoto\tCheckmol_tanimoto\t\tSIMCOMP_global\tSIMCOMP_local" $fo
echo "#done"
echo "  result: $fo"
EOF

    echo "  result: ${fo}"
    echo 
    chmod +x towork.sh tomerge.sh

fi
