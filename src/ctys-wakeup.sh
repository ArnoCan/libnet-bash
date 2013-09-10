#!/bin/bash
#
#

#
#$Header: /home2/reps/cvs/proj/ctys/ctys-rt/src/bin/ctys-wakeup.sh,v 1.3 2011/12/05 15:57:40 acue Exp $
#


########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue.opensource@gmail.com
#MAINTAINER:   Arno-Can Uestuensoez - acue.opensource@gmail.com
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      Apache-2.0
#VERSION:      01_11_003
#
########################################################################
#
#     Copyright (C) 2007,2008,2010 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
#
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
########################################################################


################################################################
#                   Begin of FrameWork                         #
################################################################


#FUNCBEG###############################################################
#
#PROJECT:
MYPROJECT="Unified Sessions Manager"
#
#NAME:
#  ctys-extractMAClst.sh
#
#AUTHOR:
AUTHOR="Arno-Can Uestuensoez - acue.opensource@gmail.com"
#
#FULLNAME:
FULLNAME="CTYS Extract MAC-Address List from dhcpd.conf"
#
#CALLFULLNAME:
CALLFULLNAME="ctys-wakeup.sh"
#
#LICENCE:
LICENCE=Apache-2.0
#
#TYPE:
#  bash-script
#
#VERSION:
VERSION=01_11_003
#DESCRIPTION:
#  Sends a magic packet to:
#
#    current segment 
#    remote segment
#
#
#EXAMPLE:
#
#PARAMETERS:
#
#  refer to online help "-h" and/or "-H"
#
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    Standard output is screen.
#
#FUNCEND###############################################################


################################################################
#                     Global shell options.                    #
################################################################
shopt -s nullglob



################################################################
#       System definitions - do not change these!              #
################################################################

C_EXECLOCAL=1;

#Execution anchor
MYCALLPATHNAME=$0
MYCALLNAME=`basename $MYCALLPATHNAME`
MYCALLNAME=${MYCALLNAME%.sh}
MYCALLPATH=`dirname $MYCALLPATHNAME`

#
#If a specific library is forced by the user
#
if [ -n "${CTYS_LIBPATH}" ];then
    MYLIBPATH=$CTYS_LIBPATH
    MYLIBEXECPATHNAME=${CTYS_LIBPATH}/bin/$MYCALLNAME
else
    MYLIBEXECPATHNAME=$MYCALLPATHNAME
fi

#
#identify the actual location of the callee
#
if [ -n "${MYLIBEXECPATHNAME##/*}" ];then
	MYLIBEXECPATHNAME=${PWD}/${MYLIBEXECPATHNAME}
fi
MYLIBEXECPATH=`dirname $MYLIBEXECPATHNAME`

###################################################
#load basic library required for bootstrap        #
###################################################
MYBOOTSTRAP=${MYLIBEXECPATH}/bootstrap
if [ ! -d "${MYBOOTSTRAP}" ];then
    MYBOOTSTRAP=${MYCALLPATH}/bootstrap
    if [ ! -d "${MYBOOTSTRAP}" ];then
	echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYBOOTSTRAP=${MYBOOTSTRAP}"
	cat <<EOF  

DESCRIPTION:
  This directory contains the common mandatory bootstrap functions.
  Your installation my be erroneous.  

SOLUTION-PROPOSAL:
  First of all check your installation, because an error at this level
  might - for no reason - bypass the final tests.

  If this does not help please send a bug-report.

EOF
	exit 1
    fi
fi

MYBOOTSTRAP=${MYBOOTSTRAP}/bootstrap.01.01.008.sh
if [ ! -f "${MYBOOTSTRAP}" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYBOOTSTRAP=${MYBOOTSTRAP}"
cat <<EOF  

DESCRIPTION:
  This file contains the common mandatory bootstrap functions required
  for start-up of any shell-script within this package.

  It seems though your installation is erroneous or you detected a bug.  

SOLUTION-PROPOSAL:
  First of all check your installation, because an error at this level
  might - for no reason - bypass the final tests.

  When your installation seems to be OK, you may try to set a TEMPORARY
  symbolic link to one of the files named as "bootstrap.<highest-version>".
  
    ln -s ${MYBOOTSTRAP} bootstrap.<highest-version>

  in order to continue for now. 

  Be aware, that any installation containing the required file will replace
  the symbolic link, because as convention the common boostrap files are
  never symbolic links, thus only recognized as a temporary workaround to 
  be corrected soon.

  If this does not work you could try one of the other versions.

  Please send a bug-report.

EOF
  exit 1
fi

###################################################
#Start bootstrap now                              #
###################################################
. ${MYBOOTSTRAP}
###################################################
#OK - utilities to find components of this version#
#available now.                                   #
###################################################

#
#set real path to install, resolv symbolic links
_MYLIBEXECPATHNAME=`bootstrapGetRealPathname ${MYLIBEXECPATHNAME}`
MYLIBEXECPATH=`dirname ${_MYLIBEXECPATHNAME}`

_MYCALLPATHNAME=`bootstrapGetRealPathname ${MYCALLPATHNAME}`
MYCALLPATHNAME=`dirname ${_MYCALLPATHNAME}`

#
###################################################
#Now find libraries might perform reliable.       #
###################################################


#current language, not really NLS
MYLANG=${MYLANG:-en}

#path for various loads: libs, help, macros, plugins
MYLIBPATH=${CTYS_LIBPATH:-`dirname $MYLIBEXECPATH`}

#path for various loads: libs, help, macros, plugins
MYHELPPATH=${MYHELPPATH:-$MYLIBPATH/help/$MYLANG}


###################################################
#Check master hook                                #
###################################################
bootstrapCheckInitialPath
###################################################
#OK - Now should work.                            #
###################################################

MYCONFPATH=${MYCONFPATH:-$MYLIBPATH/conf/ctys}
if [ ! -d "${MYCONFPATH}" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYCONFPATH=${MYCONFPATH}"
  exit 1
fi

if [ -f "${MYCONFPATH}/versinfo.conf.sh" ];then
    . ${MYCONFPATH}/versinfo.conf.sh
fi

MYMACROPATH=${MYMACROPATH:-$MYCONFPATH/macros}
if [ ! -d "${MYMACROPATH}" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYMACROPATH=${MYMACROPATH}"
  exit 1
fi

MYPKGPATH=${MYPKGPATH:-$MYLIBPATH/plugins}
if [ ! -d "${MYPKGPATH}" ];then
  echo "${MYCALLNAME}:$LINENO:ERROR:Missing:MYPKGPATH=${MYPKGPATH}"
  exit 1
fi

MYINSTALLPATH= #Value is assigned in base. Symbolic links are replaced by target


##############################################
#load basic library required for bootstrap   #
##############################################
. ${MYLIBPATH}/lib/base.sh
. ${MYLIBPATH}/lib/libManager.sh
#
#Germish: "Was the egg or the chicken first?"
#
#..and prevent real load order for later display.
#
bootstrapRegisterLib
baseRegisterLib
libManagerRegisterLib
##############################################
#Now the environment is armed, so let's go.  #
##############################################

if [ ! -d "${MYINSTALLPATH}" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:MYINSTALLPATH=${MYINSTALLPATH}"
    gotoHell ${ABORT}
fi

MYOPTSFILES=${MYOPTSFILES:-$MYLIBPATH/help/$MYLANG/*_base_options} 
checkFileListElements "${MYOPTSFILES}"
if [ $? -ne 0 ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing:MYOPTSFILES=${MYOPTSFILES}"
    gotoHell ${ABORT}
fi


################################################################
# Main supported runtime environments                          #
################################################################
#release
TARGET_OS="Linux: CentOS/RHEL(5+), SuSE-Professional 9.3"

#to be tested - coming soon
TARGET_OS_SOON="OpenBSD+Linux(might work for any dist.):Ubuntu+OpenSuSE"

#to be tested - might be almsot OK - but for now FFS
#...probably some difficulties with desktop-switching only?!
TARGET_OS_FFS="FreeBSD+Solaris/SPARC/x86"

#release
TARGET_WM="Gnome + fvwm"

#to be tested - coming soon
TARGET_WM_SOON="xfce"

#to be tested - coming soon
TARGET_WM_FORESEEN="KDE(might work now)"

################################################################
#                     End of FrameWork                         #
################################################################


#
#Verify OS support
#
case ${MYOS} in
    Linux);;
    FreeBSD|OpenBSD);;
    CYGWIN);;
    *)
        printINFO 1 $LINENO $BASH_SOURCE 1 "${MYCALLNAME} is not supported on ${MYOS}"
	gotoHell 0
	;;
esac

. ${MYLIBPATH}/lib/help/help.sh
. ${MYLIBPATH}/lib/misc.sh
. ${MYLIBPATH}/lib/security.sh
. ${MYLIBPATH}/lib/network/network.sh
. ${MYLIBPATH}/lib/groups.sh

#path to directory containing the default mapping db
if [ -d "${HOME}/.ctys/db/default" ];then
    DEFAULT_DBPATHLST=${DEFAULT_DBPATHLST:-$HOME/.ctys/db/default}
fi

#path to directory containing the default mapping db
if [ -d "${MYCONFPATH}/db/default" ];then
    DEFAULT_DBPATHLST=${DEFAULT_DBPATHLST:-$HOME/conf/db/default}
fi


if [ -d "${HOME}/.ctys" -a -d "${HOME}/.ctys/pm" ];then
    #Source pre-set environment from user
    if [ -f "${HOME}/.ctys/pm/pm.conf-${MYOS}.sh" ];then
	. "${HOME}/.ctys/pm/pm.conf-${MYOS}.sh"
    fi
fi

if [ -d "${MYCONFPATH}/pm" ];then
    #Source pre-set environment from installation 
    if [ -f "${MYCONFPATH}/pm/pm.conf-${MYOS}.sh" ];then
	. "${MYCONFPATH}/pm/pm.conf-${MYOS}.sh"
    fi
fi

#Source pre-set environment from user
if [ -f "${HOME}/.ctys/ctys.conf.sh" ];then
  . "${HOME}/.ctys/ctys.conf.sh"
fi

#Source pre-set environment from installation 
if [ -f "${MYCONFPATH}/ctys.conf.sh" ];then
  . "${MYCONFPATH}/ctys.conf.sh"
fi


#system tools
if [ -f "${HOME}/.ctys/systools.conf-${MYDIST}.sh" ];then
    . "${HOME}/.ctys/systools.conf-${MYDIST}.sh"
else

    if [ -f "${MYCONFPATH}/systools.conf-${MYDIST}.sh" ];then
	. "${MYCONFPATH}/systools.conf-${MYDIST}.sh"
    else
	if [ -f "${MYLIBEXECPATH}/../conf/ctys/systools.conf-${MYDIST}.sh" ];then
	    . "${MYLIBEXECPATH}/../conf/ctys/systools.conf-${MYDIST}.sh"
	else
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing system tools configuration file:\"systools.conf-${MYDIST}.sh\""
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Check your installation."
	    gotoHell ${ABORT}
	fi
    fi
fi


################################################################
#    Default definitions - User-Customizable  from shell       #
################################################################
_port=9;

_ARGS=;
_ARGSCALL=$*;
_RUSER0=;

for i in $*;do
    case $1 in
	'-d')shift;shift;;
	'-i')shift;_if=${1};shift;;
	'-n')_noexe=0;shift;;
	'-t')shift;_tcp=$1;shift;;
	'-p')shift;_port=${1};shift;;

	'-H'|'--helpEx'|'-helpEx')shift;_HelpEx="${1:-$MYCALLNAME}";shift;;
	'-h'|'--help'|'-help')_showToolHelp=1;shift;;
	'-V')_printVersion=1;shift;;
	'-X')C_TERSE=1;shift;;

        -*)
	    ABORT=1;
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Unkown option:\"$1\""
	    gotoHell ${ABORT}
	    ;;
    esac
    
done


if [ -n "$_HelpEx" ];then
    printHelpEx "${_HelpEx}";
    exit 0;
fi
if [ -n "$_showToolHelp" ];then
    showToolHelp;
    exit 0;
fi
if [ -n "$_printVersion" ];then
    printVersion;
    exit 0;
fi


if [ -z "$1" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Missing MAC address for target NIC."
    gotoHell ${ABORT}
fi

if [ "$1" != "$*" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Unknown options:$*"
    gotoHell ${ABORT}
fi
_mac=$*


if [ -n "$_tcp" -a -n "$_if" ];then
    ABORT=1;
    printERR $LINENO $BASH_SOURCE ${ABORT} "Only none or one is allowed:\"-t\" or \"-i\""
    gotoHell ${ABORT}
fi


printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "_mac =${_mac}"
printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "_tcp =${_tcp}"
printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "_if  =${_if}"
printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "_port=${_port}"

function buildWOLMagicPacket () {
    local _mac=$1;shift
    declare -a _pdu;

    function macAsc2Hex () {
	for i in ${@};do
	    printf "\\\\x$i"
	done
    }

    #frame
    _pdu=(ff ff ff ff ff ff);

    #MAC addr in "little endian"
    addr=(${_mac//:/ })
    addrNoEndian=(${addr[0]} ${addr[1]} ${addr[2]} ${addr[3]} ${addr[4]} ${addr[5]});

    #add 16 duplications
    for((i=0;i<16;i++));do
	for m in ${addrNoEndian[@]};do
	    size=${#_pdu[@]}
	    _pdu[${size}]=$m
	done
    done

    macAsc2Hex ${_pdu[@]}
}

function remoteWOL () {
    local _dbg1=${C_DARGS:+ -v }
    local _wait=2

    if [ -z "${CTYS_NETCAT0}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "Requires a CTYS_NETCAT0=netcat/nc version."
	gotoHell ${ABORT}
    fi

    if [ -n "$_tcp" ];then
	if [ -z "$_noexe" ];then
            _call="printf \"`buildWOLMagicPacket $_mac`\"|${CTYS_NETCAT0} $_dbg1 -u -w $_wait $_tcp $_port"
	    printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "$_call"

	    printf "`buildWOLMagicPacket $_mac`"|${CTYS_NETCAT0} $_dbg1 -u -w $_wait $_tcp $_port
	    printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "=>$?"
	else
	    buildWOLMagicPacket $_mac;echo -n -e "|${CTYS_NETCAT0} $_dbg1 -u -w $_wait $_tcp $_port"
	fi
    else
	if [ -z "$_noexe" ];then
            _call="printf \"`buildWOLMagicPacket $_mac`\n\"|${CTYS_NETCAT0} $_dbg1 -u -w $_wait  255.255.255.255 $_port"
	    printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "$_call"

	    printf "`buildWOLMagicPacket $_mac`"|${CTYS_NETCAT0} $_dbg1 -u -w $_wait 255.255.255.255 $_port
	    printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "=>$?"
	else
	    buildWOLMagicPacket $_mac;echo -n -e "|${CTYS_NETCAT0} $_dbg1 -u -w $_wait 255.255.255.255 $_port"
	fi
    fi
}


#to be replaced later
function localWOL () {
    local _dbg1=${C_DARGS:+ -D }
    local _ret=0;

    #an actual ethernet frame only
    function useEtherWake (){
	local PMCALL=;
	checkedSetSUaccess  "${_myHint}" PMCALL   CTYS_WOL_LOCAL  -i lo 11:22:33:44:55:66
	if [ $? -eq 0 ];then
	    CTYS_WOL_LOCAL="$PMCALL $CTYS_WOL_LOCAL"
	else
	    CTYS_WOL_LOCAL="echo \"Missing permission in $BASH_SOURCE:$LINENO->$PMCALL $CTYS_WOL_LOCAL\";gotoHell 1;"
	fi
	CTYS_WOL_LOCAL_WAKEUP="$CTYS_WOL_LOCAL"
	printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_WOL_LOCAL=$CTYS_WOL_LOCAL"
	printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_WOL_LOCAL_WAKEUP=$CTYS_WOL_LOCAL_WAKEUP"

	CTYS_WOL_LOCAL_WAKEUP="${CTYS_WOL_LOCAL} $_dbg1 -b -i ${_if} $_mac"

	printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "${CTYS_WOL_LOCAL_WAKEUP}"
	${CTYS_WOL_LOCAL_WAKEUP}
	_ret=$?
	printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "=>$_ret"   
    }

    #a UDP broadcast, same as remoteWOL, thus use own script
    function useWOL (){
	local PMCALL=;
	checkedSetSUaccess  "${_myHint}" PMCALL   CTYS_WOL_LOCAL  -V >/dev/null
	if [ $? -eq 0 ];then
	    CTYS_WOL_LOCAL="$PMCALL $CTYS_WOL_LOCAL"
	else
	    CTYS_WOL_LOCAL="echo \"Missing permission in $BASH_SOURCE:$LINENO->$PMCALL $CTYS_WOL_LOCAL\";gotoHell 1;"
	fi
	CTYS_WOL_LOCAL_WAKEUP="${CTYS_WOL_LOCAL} $_mac"
	printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_WOL_LOCAL=$CTYS_WOL_LOCAL"
	printDBG $S_BIN ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME CTYS_WOL_LOCAL_WAKEUP=$CTYS_WOL_LOCAL_WAKEUP"
	${CTYS_WOL_LOCAL_WAKEUP}
	_ret=$?
	printDBG $S_BIN ${D_UID} $LINENO $BASH_SOURCE "=>$_ret"   
    }

    if [ "${CTYS_WOL_LOCAL//wol/}" == "${CTYS_WOL_LOCAL}" ];then
	useEtherWake
    else
#	remoteWOL
	useWOL
    fi


}


if [ -n "$_tcp" ];then
    remoteWOL
else
    localWOL
fi


gotoHell 0
