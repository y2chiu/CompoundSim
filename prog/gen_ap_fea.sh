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
    if [ -z "$PROG_AP"      ]; then
        export PROG_AP=$WDIR"/tools/ap"
    fi
    if [ -z "$PROG_APDEF"   ]; then
        export PROG_APDEF=$WDIR"/tools/ap_DEFINITION.txt"
    fi
    if [ -z "$RID"          ]; then
        export RID=$RANDOM
    fi


    dmol=$(readlink -f $1)
    dout=$dmol

    dlog=$dout"/.log"
    dmol2=$dout"/mol2"
    dfea=$dout"/fea"

    mkdir -p $dlog
    mkdir -p $dmol2
    mkdir -p $dfea

    name=$(echo $dmol | xargs -I{} basename {} "/")
    if [ -z $name ]; then
        name="query"
    fi
    export SET_NAME=$name

    if [ ! -f "ap_DEFINITION.txt" ]; then
        cp -r $PROG_APDEF $CDIR
    fi;


    ### transfer to MOL2
    echo "#1 transfer to MOL2 files";

    fout="${dlog}/t1_trans_mol2_$RID.script"
    flog="${dlog}/t1_trans_mol2_$RID.log"
    find $dmol/ -type f -name '*.mol' -printf '%h|%f\n' | sed 's/\.mol//' | \
        awk -F"|" -v s="$PROG_TIMEOUT" -v b="$PROG_BABEL" -v mol2="$dmol2" \
        '{ printf("%s 60 %s -d -i mol %s/%s.mol -o mol2 %s/%s.mol2\n",s,b,$1,$2,mol2,$2);}' \
        > $fout
    
    echo "  script: $fout"

    if [ -z "$BLADE_MODE" ]; then
        sh $fout >$flog 2>&1

        find $dmol2/ -type f -name '*.mol2' > $dlog/lst.ap.$SET_NAME.txt
        $PROG_AP $dlog/lst.ap.$SET_NAME.txt
        php $WDIR/1_transFea.php $dlog/lst.ap.$SET_NAME-ap.txt | sort > $dfea/fea.ap.$SET_NAME
   
        echo -e "\n#2 done !!";
        echo -e "  AP feature file: $dfea/fea.ap.$SET_NAME";
    else
        jdout="$DJOB/job${RID}.tomol2"
        jscr=$fout

        mkdir -p $jdout
        cd $jdout;
        sh $PROG_TOJOB $jscr 50 towork_mol2.sh 1
        cd $CDIR;
        
        cat >> $BLADE_SCRIPT <<EOF
cd $jdout;
sh towork_mol2.sh;
cd $CDIR
EOF
        cat > $BLADE_SCRIPT.ap <<EOF
find $dmol2/ -type f -name '*.mol2' > $dlog/lst.ap.$SET_NAME.txt
$PROG_AP $dlog/lst.ap.$SET_NAME.txt
php $WDIR/1_transFea.php $dlog/lst.ap.$SET_NAME-ap.txt | sort > $dfea/fea.ap.$SET_NAME
   
echo -e "  AP feature file: $dfea/fea.ap.$SET_NAME";
EOF
        chmod +x $BLADE_SCRIPT.ap
        echo -e "  \033[1;31mrun the script: $BLADE_SCRIPT\033[m"
        echo -e "  \033[1;31mrun the script: $BLADE_SCRIPT.ap when jobs finished\033[m"
    fi
fi
