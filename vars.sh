    export WORK=$(pwd)
    export PKG_CONFIG_PATH=$WORK/lib/pkgconfig
    echo $PATH|fgrep -q $WORK/bin || export PATH=$WORK/bin:$PATH
    export CPUS=$(fgrep -c processor /proc/cpuinfo)
    export LDFLAGS=-L$WORK/lib
    export CPPFLAGS=-I$WORK/include
