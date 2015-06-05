#!/usr/bin/env bash
usage="\nUSAGE: $0 DIR_SET1 DIR_SET2 OUT_FILE_NAME\n"

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
    export WDIR=$W
    
    if [ -z $PROG_SIMCOMP ]; then 
        export PROG_SIMCOMP=$WDIR"/tools/simcomp"
    fi
    if [ -z $RID ]; then 
        RID=$RANDOM
    fi
        
    DJOB="tojob"
    mkdir -p $DJOB
    export DJOB=$(readlink -f $DJOB)


    dset1=$(readlink -f $1)
    dset2=$(readlink -f $2)
    fout=$3
    
    set1=$(echo $dset1 | xargs -I{} basename {} "/")
    set2=$(echo $dset2 | xargs -I{} basename {} "/")

    dkcf1="$dset1/kcf/"
    dkcf2="$dset2/kcf/"
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


    if [ -z "$BLADE_MODE" ]; then
        fout1=${fout}.simcomp_global.out
        fout2=${fout}.simcomp_local.out
        fout3=${fout}.simcomp_result.txt

        scr1="$DJOB/t5_align_kcf_$RID.global.script";
        scr2="$DJOB/t5_align_kcf_$RID.local.script";

        echo "#1 calculate GLOBAL simcomp"
        php $WDIR/5_simcomp.php $PROG_SIMCOMP "global" $fkcf1 $fkcf2 > $scr1
        echo "  script: $scr1"
        sh $scr1 | awk '{printf("%s|%s\t%s\n",$1,$3,$6);}' > $fout1 

        echo "#2 calculate LOCAL simcomp"
        php $WDIR/5_simcomp.php $PROG_SIMCOMP "local" $fkcf1 $fkcf2 > $scr2
        echo "  script: $scr2"
        sh $scr2 | awk '{printf("%s|%s\t%s\n",$1,$3,$6);}' > $fout2 
    
        echo "#3 merge results"

        #paste $fout1 $fout2 | cut -f 1-3,6 > $fout3
        paste $fout1 $fout2 | cut -f 1-2,4 | awk 'BEGIN{FS="[ |\t]";OFS="\t";}{NF=NF; print $0}' > $fout3

        sed -i "1i #Compound1\tCompound2\tSIMCOMP_global\tSIMCOMP_local" $fout3
    
        echo -e "#4 done !!";
        echo -e "  result: \033[1;33m$fout3\033[m";
    else
        echo "#[USING BLADE MODE]"
            
        export PROG_TOJOB=$WDIR"/scripts/tojob.sh"
        export CDIR=$(readlink -f $PWD)
    
        dout1="$DJOB/job${RID}.simcomp_gl"
        dout2="$DJOB/job${RID}.simcomp_lo"
    
        scr1="$DJOB/job${RID}.simcomp.gl.script";
        scr2="$DJOB/job${RID}.simcomp.lo.script";

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
echo -e "#done"
echo -e "  result: \033[1;33m$fout3\033[m"
EOF

        if [ -z "$ALL_MODE" ]; then
            echo -e "#5 run scripts"
            echo -e "  \033[1;31mrun towork_simcomp.sh to submit jobs\033[m"
            echo -e "  \033[1;31mrun tomerge_simcomp.sh to merge all results when jobs finished\033[m"
            echo
        else
            echo -e "#5 run scripts"
            echo -e "  \033[mrun towork_simcomp.sh to submit jobs\033[m"
            echo -e "  \033[mrun tomerge_simcomp.sh to merge all results when jobs finished\033[m"
            echo
        fi

        chmod +x towork_simcomp.sh tomerge_simcomp.sh
    fi
fi
