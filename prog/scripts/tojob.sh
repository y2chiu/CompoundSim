
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
    split -a 4 -d -l $n $1 job
    find ${PWD} -type f -name 'job*' -printf 'qsub %p\n' | sort > $o
    chmod +x job*

fi
