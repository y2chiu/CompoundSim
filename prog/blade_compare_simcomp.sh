#!/usr/bin/env bash
usage="\nUSAGE: $0 DIR_SET1 DIR_SET2 OUT_FILE_NAME\n"

if [ $# -ne 3 ] ; then
    echo " !! [ERROR] Missing arguments!!"
    echo -e ${usage}
    exit 1
elif [ ! -d $1 ] ; then
    echo " !! [ERROR] DIR_SET1: ${1} doesn't exist"
    echo -e ${usage}
    exit 1
elif [ ! -d $2 ] ; then
    echo " !! [ERROR] DIR_SET2: ${2} doesn't exist"
    echo -e ${usage}
    exit 1
elif [ -z $3 ] ; then
    echo -e ${usage}
    exit 1
else
    W=$(dirname $(readlink -f $0))
    # for shell without readlink 
    #W=$(cd "$(dirname "$0")" && pwd -P)
    export WDIR=$W

    if [ -z $PROG_SIMCOMP ]; then 
        PROG_SIMCOMP=$WDIR"/tools/simcomp"
    fi
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


    dset1=$(readlink -f $1)
    dset2=$(readlink -f $2)
    fout=$3
    
    set1=$(echo $dset1 | xargs -I{} basename {} "/")
    set2=$(echo $dset2 | xargs -I{} basename {} "/")

    dkcf1="$dset1/3_kcf/"
    dkcf2="$dset2/3_kcf/"
    fkcf1="$dset1/path.$set1.kcf"
    fkcf2="$dset2/path.$set2.kcf"
    
    if [ ! -d $dkcf1 ] ; then
        echo " !! [ERROR] DIR_KCF1: ${dkcf1} doesn't exist"
        exit 1;
    elif [ ! -d $dkcf2 ] ; then
        echo " !! [ERROR] DIR_KCF2: ${dkcf2} doesn't exist"
        exit 1;
    fi
        
    if [ ! -f $fkcf1 ]; then
        #echo " !! [ERROR] NO SET1 KCF PATH_FILE: ${fkcf1}" 
        find $dkcf1 -name '*.kcf' | sort > $fkcf1
    fi
    if [ ! -f $fkcf2 ]; then
        #echo " !! [ERROR] NO SET2 KCF PATH_FILE: ${fkcf2}" 
        find $dkcf2 -name '*.kcf' | sort > $fkcf2
    fi

    
    dout1="$UTMP/job${RID}.simcomp_global"
    dout2="$UTMP/job${RID}.simcomp_local"
    
    scr1="$UTMP/job${RID}_simcomp.global.script";
    scr2="$UTMP/job${RID}_simcomp.local.script";

    echo "#1 calculate GLOBAL simcomp"
    echo "  generate simcomp script: $(basename $scr1)"
    echo
    php $WDIR/5_simcomp.php $PROG_SIMCOMP "global" $fkcf1 $fkcf2 > $scr1

    echo "#2 calculate LOCAL simcomp"
    echo "  generate simcomp script: $(basename $scr2)"
    echo
    php $WDIR/5_simcomp.php $PROG_SIMCOMP "local" $fkcf1 $fkcf2 > $scr2
    
    echo "#3 generate qsub script: towork_simcomp.sh"
    echo "  simcomp global: $(basename $dout1)";
    echo "  simcomp local : $(basename $dout2)";
    echo
    
    mkdir -p $dout1
    cd $dout1;
    sh $PROG_TOJOB $scr1 50 toworkG.sh 1
    cd $CDIR;
    
    mkdir -p $dout2
    cd $dout2;
    sh $PROG_TOJOB $scr2 50 toworkL.sh 1
    cd $CDIR;

    cat > towork_simcomp.sh <<EOF
cd $dout1;
sh toworkG.sh;
cd $CDIR
cd $dout2;
sh toworkL.sh;
cd $CDIR; 
EOF

    echo "#4 generate merge script: tomerge_simcomp.sh"
    echo
    fout1=${fout}.simcomp_global.out
    fout2=${fout}.simcomp_local.out
    fout3=${fout}.simcomp_result.txt

    cat > tomerge_simcomp.sh <<EOF
cat \`find $dout1 -type f -name 'job*.o*' | sort\` | awk '{printf("%s|%s\t%s\n",\$1,\$3,\$6);}' > $fout1
cat \`find $dout2 -type f -name 'job*.o*' | sort\` | awk '{printf("%s|%s\t%s\n",\$1,\$3,\$6);}' > $fout2
php $WDIR/merge_result.php $fout1 $fout2 | awk 'BEGIN{FS="[ |\t]";OFS="\t";}{NF=NF; print \$0}' > $fout3
sed -i "1i #Compound1\tCompound2\tSIMCOMP_global\tSIMCOMP_local" $fout3
echo "#done"
echo "  result: $fout3"
EOF

    echo "#5 run scripts"
    echo "  run towork_simcomp.sh to submit jobs"
    echo "  run tomerge_simcomp.sh to merge all results when jobs finished"
    echo
    echo "  result: $fout3"
    echo 

    chmod +x towork_simcomp.sh tomerge_simcomp.sh

fi
