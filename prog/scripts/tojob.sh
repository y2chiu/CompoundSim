
jn=1;
if [ ! -z $2 ]; then
    jn=$2
fi

o="towork.sh"
if [ ! -z $3 ]; then
    o=$3
fi

ln=$(wc -l $1 | cut -d' ' -f1)
n=$(( $ln/$jn + 1 ));

if [ -f $1 ]; then

    find ${PWD} -type f -name 'job*' -delete

    if [ -z $4 ]; then
        split -a 4 -d -l $n $1 job
        find ${PWD} -type f -name 'job*' -printf 'qsub %p\n' | sort > $o
        chmod +x job*
    else
        split -a 4 -d -l $n $1 lst
        find ${PWD} -type f -name 'lst*' -printf 'sh %p\n' | sort > ${o}.job
        split -a 4 -d -l 1 ${o}.job job
        find ${PWD} -type f -name 'job*' -printf 'qsub %p\n' | sort > $o
        chmod +x job*
    fi

fi
