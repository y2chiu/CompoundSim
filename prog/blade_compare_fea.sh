#!/usr/bin/env bash
usage="USAGE: $0 DIR_SET1 DIR_SET2 OUT_FILE_NAME TH_AP TH_CM"

if [ $# -lt 3 ] && [ $# -gt 5 ]; then
    echo " !! [ERROR] Missing arguments!!"
    echo ${usage}
    exit 1
elif [ ! -d $1 ] ; then
    echo " !! [ERROR] DIR_SET1: ${1} doesn't exist"
    echo ${usage}
    exit 1
elif [ ! -d $2 ] ; then
    echo " !! [ERROR] DIR_SET2: ${2} doesn't exist"
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

    dset1=$(readlink -f $1)
    dset2=$(readlink -f $2)
    fout=$3
    th_ap=0.5
    th_cm=0.5
    
    if [ ! -z $5 ] ; then
        th_ap=$4
        th_cm=$5
    fi 
    if [ ! -z $4 ] ; then
        th_ap=$4
        th_cm=$4
    fi 
    
    set1=$(echo $dset1 | xargs -I{} basename {} "/")
    set2=$(echo $dset2 | xargs -I{} basename {} "/")

    fea1_ap=$dset1"/fea.ap."$set1
    fea1_cm=$dset1"/fea.cm."$set1
    
    if [ ! -f $fea1_ap ]; then
        echo " !! [ERROR] NO SET1 AP FEATURE FILE: ${fea1_ap}" 
        exit 1
    elif [ ! -f $fea1_cm ]; then
        echo " !! [ERROR] NO SET1 CM FEATURE FILE: ${fea1_cm}" 
        exit 1
    fi
    
    fea2_ap=$dset2"/fea.ap."$set2
    fea2_cm=$dset2"/fea.cm."$set2
    
    if [ ! -f $fea2_ap ]; then
        echo " !! [ERROR] NO SET2 AP FEATURE FILE: ${fea2_ap}" 
        exit 1
    elif [ ! -f $fea2_cm ]; then
        echo " !! [ERROR] NO SET2 CM FEATURE FILE: ${fea2_cm}" 
        exit 1
    fi

#
# For split fea_file to tmp_dir
#
    if [ -z $PROG_TOJOB ]; then 
        PROG_TOJOB=$WDIR"/scripts/tojob.sh"
    fi
    if [ -z $RID ]; then 
        RID=$RANDOM
    fi

    USER=$(whoami)
    #UTMP="/utmp/${USER}/"
    UTMP="utmp"

    if [ ! -d $UTMP ]; then
        UTMP="utmp"
        mkdir -p $UTMP
    fi  

    UTMP=$(readlink -f $UTMP)
    CDIR=$(readlink -f $PWD)
    

    fdir=$UTMP/fea.$set2
    jdir=$UTMP/job${RID}.comp_fea
    mkdir -p $fdir
    mkdir -p $jdir
    
    echo 
    echo "#[THRESHOLD] AP: ${th_ap}, CM: ${th_cm}"
    echo 
    echo "#1 calculate tanimoto similarity"
    echo "  generate qsub script: towork_fea.sh"
    echo "  output: $(basename $jdir)"
    echo

    #default split SET2
    ln=$(wc -l $fea2_ap | cut -d' ' -f1)
    jn=20
    n=$(( $ln/$jn + 1 ));

    cd $fdir;
    split -a 3 -d -l $n $fea2_ap tfea.ap
    split -a 3 -d -l $n $fea2_cm tfea.cm

    scr="$UTMP/t_comp_fea_$RID.script";
    find $fdir -name 'tfea.ap*' \
        -printf 'php '$WDIR'/4_tanimoto_pair.php '$fea1_ap' %p '$th_ap' > '$jdir'/%f.out\n' > $scr
    find $fdir -name 'tfea.cm*' \
        -printf 'php '$WDIR'/4_tanimoto_pair.php '$fea1_cm' %p '$th_ap' > '$jdir'/%f.out\n' >> $scr
    
    cd $jdir;
    sh $PROG_TOJOB $scr 40 $jdir/towork_comp_fea.sh
    cd $CDIR


    cat > towork_fea.sh <<EOF
cd $jdir;
sh towork_comp_fea.sh;
cd $CDIR;
EOF

    fout_ap=$fout.fea_tani_ap.txt
    fout_cm=$fout.fea_tani_cm.txt

    echo "#2 merge results"
    echo "  generate merge script: tomerge_fea.sh"
    echo 
    fout3=${fout}.fea_result.txt

    cat > tomerge_fea.sh <<EOF 
cat $jdir/tfea.ap*.out > $fout_ap;
cat $jdir/tfea.cm*.out > $fout_cm;
php $WDIR/merge_result.php $fout_ap $fout_cm | awk 'BEGIN{FS="[ |\t]";OFS="\t";}{NF=NF; print \$0}' > $fout3
sed -i "1i #Compound1\tCompound2\tAP_tanimoto\tCheckmol_tanimoto" $fout3
echo "#done"
echo "  result: $fout3"
EOF
    echo "#3 run scripts"
    echo "  run towork_fea.sh to submit jobs"
    echo "  run tomerge_fea.sh to merge all results when jobs finished"
    echo
    echo "  result: $fout3"
    echo 

    chmod +x towork_fea.sh tomerge_fea.sh

fi
