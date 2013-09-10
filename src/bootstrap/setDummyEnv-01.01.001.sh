
P=${1}


PATH=$PATH:/usr/bin
PATH=$P/bin::$P/conf/ctys/scripts:$PATH
export PATH

umask 077


MANPATH=$P/doc/de/man:${MANPATH};export MANPATH

CTYS_LIBPATH=$P;export CTYS_LIBPATH;
CTYS_INI=1;export CTYS_INI
