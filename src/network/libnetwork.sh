#!/bin/bash
#
#

#
#$Header: /home2/reps/cvs/proj/ctys/ctys-rt/src/lib/network/network.sh,v 1.4 2012/01/23 16:20:08 acue Exp $
#


########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue.opensource@gmail.com
#MAINTAINER:   Arno-Can Uestuensoez - acue.opensource@gmail.com
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      Apache-2.0
#VERSION:      01_11_023
#
########################################################################
#
# Copyright (C) 2007,2008,2010,2011 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myLIBNAME_network="${BASH_SOURCE}"
_myLIBVERS_network="01.11.023"
libManInfoAdd "${_myLIBNAME_network}" "${_myLIBVERS_network}"

_myLIBNAME_BASE_network="`dirname ${_myLIBNAME_network}`"


case ${MYOS} in
    Linux)
	[ -z "$CTYS_ROUTE" ]&&CTYS_ROUTE=`getPathName $LINENO $BASH_SOURCE ERROR route /sbin`
	[ -z "$CTYS_IFCONFIG" ]&&CTYS_IFCONFIG=`getPathName $LINENO $BASH_SOURCE ERROR ifconfig /sbin`
	;;
    CYGWIN)
	WBASE0=/cygdrive/c
	SYS32=${WBASE0}/*/System32/NETSTAT.EXE
	SYS32="${SYS32%/*}"
	export SYS32;
	[ -z "$CTYS_ROUTE" ]&&CTYS_ROUTE=`getPathName $LINENO $BASH_SOURCE ERROR ROUTE.EXE ${SYS32}`
	[ -z "$CTYS_IFCONFIG" ]&&CTYS_IFCONFIG=`getPathName $LINENO $BASH_SOURCE ERROR IPCONFIG.EXE ${SYS32}`
	[ -z "$CTYS_NSLOOKUP" ]&&CTYS_NSLOOKUP=`getPathName $LINENO $BASH_SOURCE WARNING NSLOOKUP.EXE ${SYS32}`
	;;
    FreeBSD|OpenBSD)
	[ -z "$CTYS_ROUTE" ]&&CTYS_ROUTE=`getPathName $LINENO $BASH_SOURCE ERROR route /sbin`
	[ -z "$CTYS_IFCONFIG" ]&&CTYS_IFCONFIG=`getPathName $LINENO $BASH_SOURCE ERROR ifconfig /sbin`
	;;
    SunOS)
	[ -z "$CTYS_ROUTE" ]&&CTYS_ROUTE=`getPathName $LINENO $BASH_SOURCE ERROR route /usr/sbin`
	[ -z "$CTYS_IFCONFIG" ]&&CTYS_IFCONFIG=`getPathName $LINENO $BASH_SOURCE ERROR ifconfig /usr/sbin`
	;;
esac


#FUNCBEG###############################################################
#NAME:
#  netGetFirstIf
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  gets the first interface
#
#  
#EXAMPLE:
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: Success
#    1: Failure
#  VALUES:
#    interface name
#
#FUNCEND###############################################################
function netGetFirstIf () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local _fif=;
    case ${MYOS} in
	Linux)
	    _fif=`${CTYS_IFCONFIG}|awk '$1!~/lo/{if(p==0){print $1;p=1;}}'`
	    ;;
	CYGWIN)
	    _fif=`${CTYS_IFCONFIG}|awk -v d=$D -f ${_myLIBNAME_BASE_network}/netGetFirstIF-${MYOS}.awk`;
	    ;;
	FreeBSD|OpenBSD)
	    _fif=`${CTYS_IFCONFIG}|awk '$1!~/lo/{if(p==0){print $1;p=1;}}'`
	    ;;
	SunOS)
	    _fif=`${CTYS_IFCONFIG} -a|awk -F':' '$1!~/lo/&&$2~/^ *flags/{if(p==0){print $1;p=1;}}'`
	    ;;
    esac
    if [ -z "${_fif}" ];then
	printERR $LINENO $BASH_SOURCE 1  "Can not evaluate first interface check \"ifconfig\"."
	gotoHell 1
    fi
    #...just trust the result?!
    echo $_fif
    return 0
}



#FUNCBEG###############################################################
#NAME:
#  netGetIfBroadcast
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Gets broadcast for given interface.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: interface
#
#OUTPUT:
#  RETURN:
#    0: Success
#    1: Failure
#  VALUES:
#    dotted-ip-broadcast 
#
#FUNCEND###############################################################
function netGetIfBroadcast () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local _if=$1
    case ${MYOS} in
	Linux)
	    local _bcast=`${CTYS_IFCONFIG} $_if|awk -F':' '/Bcast/{gsub(" *[^ ]*$","",$3);if(!f){f=0;print $3;}}'`
	    ;;
	CYGWIN)
	    local _ix=$(${CTYS_IFCONFIG} |awk -v d=$D -v id="$_if" -f ${_myLIBNAME_BASE_network}/netGetIFBroadcast-${MYOS}.awk);
	    if [ -n "$_ix" ];then
		local _bcast=$(${_myLIBNAME_BASE_network}/netGetIFBroadcast-${MYOS}.sh "$_ix");
	    fi
	    ;;
	FreeBSD|OpenBSD)
	    local _bcast=`${CTYS_IFCONFIG} $_if|awk -F':' '/Bcast/{gsub(" *[^ ]*$","",$3);if(!f){f=0;print $3;}}'`
	    ;;
	SunOS)
	    local _bcast=`${CTYS_IFCONFIG} ${_if:--a}|awk '/broadcast/{if(!f){f=0;print $NF;}}'`
	    ;;
    esac
    if [ -z "${_bcast}" ];then
	printERR $LINENO $BASH_SOURCE 1  "Can not evaluate broadcast for interface $_if check \"ifconfig\"."
	gotoHell 1
    fi
    #...just trust the result?!
    echo $_bcast
    return 0
}


#FUNCBEG###############################################################
#NAME:
#  netListBridges
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Lists all present bridges.
#
#
#EXAMPLE:
#
#  netListBridges peth
#    returns all "Xen-bridges".
#
#PARAMETERS:
# $1: [<if-prefix>]
#     This parameter is optional and provides a prefix to the interfaces 
#     which has to be present in each bridge of result list.
#
#
#OUTPUT:
#  RETURN:
#    0: Success
#    1: Failure
#  VALUES:
#    space separated list of bridge names from CTYS_BRCTL 
#
#FUNCEND###############################################################
function netListBridges () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    case ${MYOS} in
	Linux);;
	*)  printWNG 2 $LINENO $BASH_SOURCE 2  "$FUNCNAME:OS=${MYOS} not yet supported";
	    return 1;
	    ;;
    esac

    if [ -n "${CTYS_BRCTL// }" ];then
	local _b=;
	if [ -n "$1" ];then	
	    _b=`${CTYS_BRCTL} show|awk '/bridge name/{f=1;next;}f==1&&NF>1{s=$1;}f==1&&$NF~/^'$1'/{printf("%s ",s);}'`
	else
	    _b=`${CTYS_BRCTL} show|awk '/bridge name/{f=1;next;}f==1{if(NF>1)printf("%s ",$1);}'`
	fi
	_b=${_b%% }
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_b=<${_b}>"
	echo ${_b}
	return 0
    else
	printWNG 2 $LINENO $BASH_SOURCE 0  "brctl not available"
	return 1
    fi
}



#FUNCBEG###############################################################
#NAME:
#  netCheckForBridges
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Checks whether bridges are present and contain <if-prefix> on the local 
#  machine and gives a warning if not running in Dom0.
#
#
#EXAMPLE:
#
#PARAMETERS:
# $1: [<if-prefix>]
#     This parameter is optional and provides a prefix to the interfaces 
#     which has to be present in each bridge checked for match.
#
#OUTPUT:
#  RETURN:
#    0: bridges present
#    1: no bridges
#  VALUES:
#    dotted-ip-broadcast 
#
#FUNCEND###############################################################
function netCheckForBridges () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"

    if [ -n "`netListBridges $1`" ];then
	return 0
    else
	return 1
    fi
}

#FUNCBEG###############################################################
#NAME:
#  netCheckBridgeExists
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Checks whether bridge exists.
#
#
#EXAMPLE:
#PARAMETERS:
# $1: <bridge>
#
#
#OUTPUT:
#  RETURN:
#    0: exists
#    1: non-existent
#  VALUES:
#
#FUNCEND###############################################################
function netCheckBridgeExists () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    case ${MYOS} in
	Linux);;
	*)  printWNG 2 $LINENO $BASH_SOURCE 2  "$FUNCNAME:OS=${MYOS} not yet supported";
	    return 1;
	    ;;
    esac
    if [ ! -e "/sys/class/net/${1}" ];then 
	local mx="`netListBridges`"
	local x1=${1}
	mx=`echo " $mx "|sed -n "s_ ${x1//\//\\/} __p"`
	[ -n "$mx" ]&&return 0||return 1
    fi
    [ -e "/sys/class/net/${1}/bridge" ]
}


#FUNCBEG###############################################################
#NAME:
#  netListBridgePorts
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Lists all present ports of a given bridge.
#
#
#EXAMPLE:
#PARAMETERS:
# $1: <bridge>
#     This single mandatory parameter is the name of the bridge to be 
#     enumerated.
#
#
#OUTPUT:
#  RETURN:
#    0: Success
#    1: Failure
#  VALUES:
#    list of spec-seperated ports 
#
#FUNCEND###############################################################
function netListBridgePorts () {
    case ${MYOS} in
	Linux);;
	*)  printWNG 2 $LINENO $BASH_SOURCE 2  "$FUNCNAME:OS=${MYOS} not yet supported";
	    return 1;
	    ;;
    esac
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    brctl show|awk -v s=$1 '
      BEGIN{swon=0;}
      NF>2{swon=0;}
      $1==s{swon=1;}      
      swon==1{print $NF}     
      '
}



#FUNCBEG###############################################################
#NAME:
#  netGetIFlst
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Returns a space seperated list of current Ethernet interfaces with a 
#  valid MAC and/or IP address.
#
#  Specific handling of Xen bridged addressing is embedded by dropping
#  any interface with a broadcast MAC-address.
#
#  Additional interface types and a more generic interface may follow.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: This controls the scope of interfaces to be recognized.
#
#      WITHIP   List  all interfaces with a valid IP address
#      WITHMAC  Lists all interfaces with a valid MAC address
#      ALL      Lists all interfaces with a valid IP and/or MAC address
#
#  $2: This defines the specific output format required.
#
#      CONFIG   Full scope of data for configuration file.
#
#
#OUTPUT:
#  RETURN:
#    $?
#  VALUES:
#    <MAC-addr>[=<dotted-IP-addr>[%<mask>%<name>]]
#
#FUNCEND###############################################################
function netGetIFlst () {
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:@=${@}"
	local _scope=WITHIP;
	case $1 in
	    WITHIP|WITHMAC|ALL)
		_scope=$1;
		;;
	    "");;
	    *)
		printERR $LINENO $BASH_SOURCE 1  "Unknown interface scope:$1"
		gotoHell 1
		;;
	esac
	case $2 in
	    CONFIG)
		_format=$2;
		;;
	    "");;
	    *)
		printERR $LINENO $BASH_SOURCE 1  "Unknown interface format:$2"
		gotoHell 1
		;;
	esac
	doDebug $S_LIB $D_BULK $LINENO $BASH_SOURCE
	local D=$?
	local _ipx=;
	case ${MYOS} in
	    Linux)
                #temp for casual bridges
		_ipx=`${CTYS_IFCONFIG}|awk -v s=$_scope -v f=$_format -v d=$D -f ${_myLIBNAME_BASE_network}/netGetIFlst-${MYOS}.awk`;
		;;

	    CYGWIN)
		_ipx=`${CTYS_IFCONFIG} /all|awk -v s=$_scope -v f=$_format -v d=$D -f ${_myLIBNAME_BASE_network}/netGetIFlst-${MYOS}.awk`;
		;;

	    FreeBSD|OpenBSD)
		_ipx=`${CTYS_IFCONFIG}|awk -v s=$_scope -v f=$_format -v d=$D -f ${_myLIBNAME_BASE_network}/netGetIFlst-${MYOS}.awk`;
		;;
	    SunOS)
		_ipx=`${CTYS_IFCONFIG} -a|awk -v s=$_scope -v f=$_format -v d=$D -f ${_myLIBNAME_BASE_network}/netGetIFlst-${MYOS}.awk`;
		;;
	esac
	echo -n $_ipx
}


#FUNCBEG###############################################################
#NAME:
#  netCheckIfIs
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Checks whether the interface is UP.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: UP|DOWN
#  $2: Interface.
#  $3: [max-trials-with-1secTimeout]
#      This optional value causes an automatic repetition with given maximum.
#      Between each a "sleep 1" is called.
#
#OUTPUT:
#  RETURN:
#    0: yes
#    1: no
#  VALUES:
#
#FUNCEND###############################################################
function netCheckIfIs () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    local _updown=$1;
    local _iftest=$2;
    local _repetition=${3:-1};
    local _idx=;

    for _idx in `seq $_repetition`;do
	case ${MYOS} in
	    Linux)
		local _myList=`${CTYS_IFCONFIG} ${_iftest}|awk '{print " "$1" ";}'`;
		;;
	    CYGWIN)
		local _ix=$(${CTYS_IFCONFIG} |awk -v d=$D -v id="$1" -f ${_myLIBNAME_BASE_network}/netGetIFIP-${MYOS}.awk);
		if [ -n "$_ix" ];then
		    local _myList=" $1 ";
		fi
		;;
	    FreeBSD|OpenBSD)
		local _myList=`${CTYS_IFCONFIG} ${_iftest}|awk '{print " "$1" ";}'`;
		;;
	    SunOS)
#		local _myList=`${CTYS_IFCONFIG} -a ${_iftest}|awk '{print " "$1" ";}'`;
		local _myList=`${CTYS_IFCONFIG}  ${_iftest}|awk '{print " "$1" ";}'`;
		;;
	esac
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:_myList=<${_myList}>"
	local x2=${1}
	_myList=`echo " ${_myList} "|sed -n "s_.* ${x2//\//\\/} .*_1_p"`;
	case $_updown in
	    UP)
		if [ -n "${_myList}" ];then
		    return 0
		fi
		;;
	    DOWN)
		if [ -z "${_myList}" ];then
		    return 0
		fi
		;;
	    *)
		printERR $LINENO $BASH_SOURCE 1  "Unknown:$updown"
		gotoHell 1
		;;
	esac
	[ "$_repetition" != 1 ]&&sleep 1;
    done
    return 1
}

#FUNCBEG###############################################################
#NAME:
#  netGetMAC
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function netGetMAC () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME"
    local _mac=;
    case ${MYOS} in
	Linux)
	    _mac=`${CTYS_IFCONFIG} |awk '/Link encap:Ethernet/{if(p==0){p=1;print $NF}}'`;
	    ;;
	CYGWIN)
	    _mac=$(${CTYS_IFCONFIG} /all |awk -v d=$D -v id=0 -f ${_myLIBNAME_BASE_network}/netGetIFMAC-${MYOS}.awk);
	    ;;
	FreeBSD|OpenBSD)
	    _mac=`${CTYS_IFCONFIG} |awk '
            /flags=/&&$1!~/lo0/ {if(p==0){p=1;}}
            /lladdr /&&p==1      {print $2;p=2;}
            '`;
	    ;;
	SunOS)
	    _mac=`${CTYS_IFCONFIG} -a|awk '/ether/{if(p==0){p=1;print $2;}}'`;
	    ;;
    esac
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_mac=$_mac"
    echo -n $_mac
}


#FUNCBEG###############################################################
#NAME:
#  netGetIP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function netGetIP () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME"
    local _ip=;
    case ${MYOS} in
	Linux)
	    _ip=`${CTYS_IFCONFIG} |awk '/inet /{if(p==0){p=1;print $2}}'|awk -F':' '{print $2}'`;
	    ;;
	CYGWIN)
	    _ip=$(${CTYS_IFCONFIG} |awk -v d=$D -v id=0 -f ${_myLIBNAME_BASE_network}/netGetIFIP-${MYOS}.awk);
	    ;;
	FreeBSD|OpenBSD)
	    _ip=`${CTYS_IFCONFIG} |awk '
            /flags=/&&$1!~/lo0/ {if(p==0){p=1;}}
            /inet /&&p==1        {print $2;p=2;}
            '`;
	    ;;
	SunOS)
	    _ip=`${CTYS_IFCONFIG} -a|awk '/inet /{if(p==0){p=1;print $2}}'`;
	    ;;
    esac
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:ip=$_ip"
    echo -n $_ip
}


#FUNCBEG###############################################################
#NAME:
#  netGetMask
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  optional list of parameters
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function netGetMask () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME"
    local _ip=;
    case ${MYOS} in
	Linux)
	    _ip=`${CTYS_IFCONFIG} ${1} |awk '/inet /{if(p==0){p=1;if($4!~/^$/){print $4}else{print $NF}}}'|awk -F':' '{print $2}'`;
	    ;;
	CYGWIN)
	    _ip=$(${CTYS_IFCONFIG} |awk -v d=$D -v id=0 -f ${_myLIBNAME_BASE_network}/netGetIFMask-${MYOS}.awk);
	    ;;
	FreeBSD|OpenBSD)
	    _ip=`${CTYS_IFCONFIG} ${1} |awk '
            /flags=/&&$1!~/lo0/ {if(p==0){p=1;}}
            /inet /&&p==1        {print $2;p=4;}
            '`;
	    ;;
	SunOS)
	    _ip=`${CTYS_IFCONFIG} ${1:--a} |awk '/inet /{if(p==0){p=1;print $4}}'`;
	    ;;
    esac
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:netmask=$_ip"
    echo -n $_ip
}


#FUNCBEG###############################################################
#NAME:
#  netGetBroadcast
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function netGetBroadcast () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME"
    local _ip=;
    case ${MYOS} in
	Linux)
	    _ip=`${CTYS_IFCONFIG} |awk '/inet /{if(p==0){p=1;print $3}}'|awk -F':' '{print $2}'`;
	    ;;

	CYGWIN)
	    local _ix=$(${CTYS_IFCONFIG} |awk -v d=$D -v id=0 -f ${_myLIBNAME_BASE_network}/netGetIFBroadcast-${MYOS}.awk);
	    if [ -n "$_ix" ];then
		local _ip=$(${_myLIBNAME_BASE_network}/netGetIFBroadcast-${MYOS}.sh "$_ix");
	    fi
	    ;;

	FreeBSD|OpenBSD)
	    _ip=`${CTYS_IFCONFIG}|awk '
            /flags=/&&$1!~/lo0/ {if(p==0){p=1;}}
            /inet /&&p==1        {print $2;p=6;}
            '`;
	    ;;
	SunOS)
	    _ip=`${CTYS_IFCONFIG} -a|awk '/inet /{if(p==0){p=1;print $NF;}'`;
	    ;;
    esac
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:netmask=$_ip"
    echo -n $_ip
}


#FUNCBEG###############################################################
#NAME:
#  netGetUNIXDomainSocket
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <master-pid>
#  $2: <label>
#  $3: <UNIX-Domain-Socket-Pattern>
#        "<absolute-path-prefix>/<context-prefix>.ACTUALLABEL.ACTUALPID.<user-owner>"
#
#
#OUTPUT:
#  RETURN:
#  <resolved-UNIX-Domain-Socket>
#        "<absolute-path-prefix>/<context-prefix>.<label>.<masterpid>.<user-owner>"
#
#  VALUES:
#
#FUNCEND###############################################################
function netGetUNIXDomainSocket () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"

    local UNIXSOCK=${3}
    UNIXSOCK=${UNIXSOCK//ACTUALLABEL/$2}
    UNIXSOCK=${UNIXSOCK//ACTUALPID/$1}

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:UNIXSOCK=<${UNIXSOCK}>"
    echo -n $UNIXSOCK
}


#FUNCBEG###############################################################
#NAME:
#  netGetProcTAPList
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function netGetProcTAPList () {
    case ${MYOS} in
	Linux);;
	*)  printWNG 2 $LINENO $BASH_SOURCE 2  "$FUNCNAME:OS=${MYOS} not yet supported";
	    return 1;
	    ;;
    esac
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    local _val=`cat /proc/net/dev|sed 's_^ *__'|awk -F':' '$1~/^tap[0-9]*/printf("%s ",$1);}'`
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:results from /proc/net/dev:=<${_val}>"
    echo -n "$_val"
}

#FUNCBEG###############################################################
#NAME:
#  netGetProcEthList
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Currently for Linux only.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: This controls the scope of interfaces to be recognized.
#
#      ALL      Lists all interfaces without restrictions
#      PREFIX   Lists all interfaces with prefix
#      POSFTIX  Lists all interfaces with postfix
#      MATCH    Lists all interfaces with match
#
#  $2: Optional name string, 
#      default 
#       -> for Linux: eth
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function netGetProcEthList () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"

    local cx=PREFIX;
    case "$1" in
	ALL|PREFIX|POSTFIX|MATCH)cx=$1;;
    esac
    local st=${2:-eth}
    case ${MYOS} in
	Linux);;
	*)  printWNG 2 $LINENO $BASH_SOURCE 2  "$FUNCNAME:OS=${MYOS} not yet supported";
	    return 1;
	    ;;
    esac
    local _val=`cat /proc/net/dev|sed 's_^ *__'|\
    case $cx in
      ALL)     awk -F':' -v s="$st" '$1~/^[a-z]+[0-9.]+/{printf("%s ",$1);}';;
      MATCH)   awk -F':' -v s="$st" '$1~/^.*'"$st"'.*[0-9.]+/{printf("%s ",$1);}';;
      PREFIX)  awk -F':' -v s="$st" '$1~/^'"$st"'[0-9.]+/{printf("%s ",$1);}';;
      POSTFIX) awk -F':' -v s="$st" '$1~/^.*'"$st"'[0-9.]+/{printf("%s ",$1);}';;
    esac`
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:results from /proc/net/dev:=<${_val}>"
    echo -n "$_val"
}



#FUNCBEG###############################################################
#NAME:
#  netCheckIsBonding
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Checks whether the interface is a bonding device.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: Interface.
#
#
#OUTPUT:
#  RETURN:
#    0: true
#    1: false
#  VALUES:
#
#FUNCEND###############################################################
function netCheckIsBonding () {
    case ${MYOS} in
	Linux);;
	*)  printWNG 2 $LINENO $BASH_SOURCE 2  "$FUNCNAME:OS=${MYOS} not yet supported";
	    return 1;
	    ;;
    esac
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=<${@}>"
    if [ -f "/sys/class/net/$1/bonding/slaves" ];then
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:true<${1}>"
	return 0
    else
	printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:false<${1}>"
	return 1
    fi
}


#FUNCBEG###############################################################
#NAME:
#  netCheckIsXen
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Checks whether running in Dom0.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: true
#    1: false
#  VALUES:
#
#FUNCEND###############################################################
function netCheckIsXen () {
    case ${MYOS} in
	Linux);;
	*)  printWNG 2 $LINENO $BASH_SOURCE 2  "$FUNCNAME:OS=${MYOS} not yet supported";
	    return 1;
	    ;;
    esac
    local _cap="/sys/hypervisor/properties/capabilities"
    [ -e "$_cap" ]&&grep -q xen $_cap
}


#FUNCBEG###############################################################
#NAME:
#  netCheckBridgeIsXen
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Checks whether running in Dom0.
#
#EXAMPLE:
#
#PARAMETERS:
#  $*:  List of bridges to check
#
#OUTPUT:
#  RETURN:
#    0: true
#    1: false
#  VALUES:
#
#FUNCEND###############################################################
function netCheckBridgeIsXen () {
    case ${MYOS} in
	Linux);;
	*)  printWNG 2 $LINENO $BASH_SOURCE 2  "$FUNCNAME:OS=${MYOS} not yet supported";
	    return 1;
	    ;;
    esac
    local _ret=0;
    local _x=;
    local i=;
    local j=;
    if [ -n "${FORCE_THIS_IS_XEN_BRIDGE}" ];then
	_x=1;
	for i in $*;do
	    if [ "${FORCE_THIS_IS_XEN_BRIDGE}" == "$i" ];then
		_x=0;
		echo -n "$i "
	    fi
	done
	return $_x;
    fi

    local _blst=$*
    local _xlst=$(netListBridges peth)

    for i in $_xlst;do
	_x=1;
	for j in $_blst;do
	    if [ $i == $j ];then
		_x=0;
		echo -n "$j "
	    fi
	done
	let _ret+=_x;
    done
    if((_ret==0));then 
	printWNG 2 $LINENO $BASH_SOURCE 2  "$FUNCNAME:NO XenBridges found.";
	printWNG 2 $LINENO $BASH_SOURCE 2  "$FUNCNAME:Assume XenBridge has a 'peth'.";
    fi
    return $_ret;
}


#FUNCBEG###############################################################
#NAME:
#  netTransferAddr
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Original Xen-3.0.x
#
#  Transfers addresses from one interface to another.
#
#  Copy all IP addresses (including aliases) from device $src to device $dst.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: src
#  $2: dst
#
#OUTPUT:
#  RETURN:
#    0: true
#    1: false
#  VALUES:
#
#FUNCEND###############################################################
function netTransferAddr () {
    case ${MYOS} in
	Linux);;
	*)  printWNG 2 $LINENO $BASH_SOURCE 2  "$FUNCNAME:OS=${MYOS} not yet supported";
	    return 1;
	    ;;
    esac
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local src=$1
    local dst=$2
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "src=$src dst=$dst"

    local lCTYSIP=${CTYS_IP}

    # Don't bother if $dst already has IP addresses.
    if $CTYS_IP addr show dev ${dst} | egrep -q '^ *inet ' ; then
        return
    fi
    # Address lines start with 'inet' and have the device in them.
    # Replace 'inet' with 'ip addr add' and change the device name $src
    # to 'dev $src'.
    local _call=`${lCTYSIP} addr show dev ${src}|sed  -n "s_  *inet  *\(.\+\)${src//\//\\/}_""${lCTYSIP//\//\\/}"" addr add \1 dev ${dst//\//\\/}_p"`
    if [ -n "${_call}" ];then
	callErrOutWrapper $LINENO $BASH_SOURCE ${_call} >/dev/null
    fi
    # Remove automatic routes on destination device

    callErrOutWrapper $LINENO $BASH_SOURCE ${lCTYSIP} route list | sed -ne "/dev ${dst//\//\\/}\( \|$\)/ {s_.*_del & _p;}"|\
    while read X;do
	{ callErrOutWrapper $LINENO $BASH_SOURCE ${lCTYSIP} route $X ; }
    done


}


#FUNCBEG###############################################################
#NAME:
#  netTransferRoute
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Idea from Xen-3.0.x
#
#  Transfers routes from one interface to another.
#
#  Get all IP routes to device $src, delete them, and
#  add the same routes to device $dst.
#  The original routes have to be deleted, otherwise adding them
#  for $dst fails (duplicate routes).
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: src
#  $2: dst
#
#OUTPUT:
#  RETURN:
#    0: true
#    1: false
#  VALUES:
#
#FUNCEND###############################################################
function netTransferRoute () {
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    case ${MYOS} in
	Linux);;
	*)  printWNG 2 $LINENO $BASH_SOURCE 2  "$FUNCNAME:OS=${MYOS} not yet supported";
	    return 1;
	    ;;
    esac
    local src=$1
    local dst=$2
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "src=$src dst=$dst"


    # List all routes and grep the ones with $src in.
    # Stick 'ip route del' on the front to delete.
    # Change $src to $dst and use 'ip route add' to add.

    export -f printDBG
    export -f callErrOutWrapper

    case $MYOS in
	Linux)
	    { callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_ROUTE} -n ; }|\
            awk -v src="${src}" -v dst="${dst}" '
              $NF~src&&$4~/G/{
                 nmask=gsub("0.0.0.0","",$3);
                 if(nmask==0){
                   xstr=sprintf("-net %s netmask %s gw %s dev ",$1,$3,$2);
                 }else{
                   xstr=sprintf("-net %s gw %s dev ",$1,$2);
                 }
                 print "delete "xstr" "src;
                 print "add "xstr" "dst;
              }
              $NF~src&&$4!~/G/{
                 xstr=sprintf("-net %s netmask %s dev",$1, $3);
                 print "delete "xstr" "src;
                 print "add "xstr" "dst;
              }'|\
            while read X;do
		{ callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_ROUTE} $X ; }
	    done
	    ;;
	FreeBSD|OpenBSD)
            #adds in standard usage for host routes a default gateway for networks, thus 
            #host transfer is obsolete(even fails)
            #route add -host 192.168.3.111 -netmask 255.255.255.0 gw1
            #route delete -host 192.168.3.111 -netmask 255.255.255.0 gw1 =>err
            #route delete -net 192.168.3 -netmask 255.255.255.0 gw1      =>ok
            #route delete -net 192.168.3 gw1                             =>ok
          
	    { callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_ROUTE} -n show -inet ; }|\
            awk -v src="${src}" -v dst="${dst}" '
              $NF~src&&$4~/3/{
                   print "delete -net "$1" "$2" -ifp "src;
                   print "add    -net "$1" "$2" -ifp "dst;
              }'|\
            while read X;do
		{ callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_IP} route -n $X ; }
	    done
	    ;;
	SunOS)
            #adds in standard usage for host routes a default gateway for networks, thus 
            #host transfer is obsolete(even fails)
            #route add -host 192.168.3.111 -netmask 255.255.255.0 gw1
            #route delete -host 192.168.3.111 -netmask 255.255.255.0 gw1 =>err
            #route delete -net 192.168.3 -netmask 255.255.255.0 gw1      =>ok
            #route delete -net 192.168.3 gw1                             =>ok
          
	    { callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_ROUTE} -n show -inet ; }|\
            awk -v src="${src}" -v dst="${dst}" '
              $NF~src&&$4~/3/{
                   print "delete -net "$1" "$2" -ifp "src;
                   print "add    -net "$1" "$2" -ifp "dst;
              }'|\
            while read X;do
		{ callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_IP} route -n $X ; }
	    done
	    ;;
    esac
}


#FUNCBEG###############################################################
#NAME:
#  netClearRoute
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Idea from Xen-3.0.x
#
#  Clears routing entries for given entity.
#
#EXAMPLE:
#
#PARAMETERS:
#  INTERFACE
#    $1: INTERFACE
#    $2: <interface>
#
#OUTPUT:
#  RETURN:
#    0: true
#    1: false
#  VALUES:
#
#FUNCEND###############################################################
function netClearRoute () {
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    case ${MYOS} in
	Linux);;
	*)  printWNG 2 $LINENO $BASH_SOURCE 2  "$FUNCNAME:OS=${MYOS} not yet supported";
	    return 1;
	    ;;
    esac
    local _type=$1
    local _value=$2
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "_type=$_type value=$_value"

    export -f printDBG
    export -f callErrOutWrapper

    function doLinux () {
	local _type=$1
	local _value=$2
	case $_type in
	    INTERFACE)
		{ callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_ROUTE} -n ; }|\
            awk -v src="${_value}" '
              $NF~src&&$4~/G/{
                 nmask=gsub("0.0.0.0","",$3);
                 if(nmask==0){
                   xstr=sprintf("-net %s netmask %s gw %s dev ",$1,$3,$2);
                 }else{
                   xstr=sprintf("-net %s gw %s dev ",$1,$2);
                 }
                 print "delete "xstr" "src;
              }
              $NF~src&&$4!~/G/{
                 xstr=sprintf("-net %s netmask %s dev",$1, $3);
                 print "delete "xstr" "src;
              }'|\
            while read X;do
		    { callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_ROUTE} $X ; }
		done
		;;
	    *)
		;;
	esac
    }

    function doOpenBSD () {
	local _type=$1
	local _value=$2
	case $_type in
	    INTERFACE)
            #adds in standard usage for host routes a default gateway for networks, thus 
            #host transfer is obsolete(even fails)
            #route add -host 192.168.3.111 -netmask 255.255.255.0 gw1
            #route delete -host 192.168.3.111 -netmask 255.255.255.0 gw1 =>err
            #route delete -net 192.168.3 -netmask 255.255.255.0 gw1      =>ok
            #route delete -net 192.168.3 gw1                             =>ok
		
		{ callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_ROUTE} -n show -inet ; }|\
            awk -v src="${_value}" '
              $NF~src&&$4~/3/{
                   print "delete -net "$1" "$2" -ifp "src;
              }'|\
            while read X;do
		    { callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_IP} route -n $X ; }
		done
		;;
	    *)
		;;
	esac
    }

    function doSunOS () {
	local _type=$1
	local _value=$2
	case $_type in
	    INTERFACE)
            #adds in standard usage for host routes a default gateway for networks, thus 
            #host transfer is obsolete(even fails)
            #route add -host 192.168.3.111 -netmask 255.255.255.0 gw1
            #route delete -host 192.168.3.111 -netmask 255.255.255.0 gw1 =>err
            #route delete -net 192.168.3 -netmask 255.255.255.0 gw1      =>ok
            #route delete -net 192.168.3 gw1                             =>ok
		
		{ callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_ROUTE} -n show -inet ; }|\
            awk -v src="${_value}" '
              $NF~src&&$4~/3/{
                   print "delete -net "$1" "$2" -ifp "src;
              }'|\
            while read X;do
		    { callErrOutWrapper $LINENO $BASH_SOURCE ${CTYS_IP} route -n $X ; }
		done
		;;
	    *)
		;;
	esac
    }

    case $MYOS in
	Linux)
	    doLinux "$_type" "$_value"
	    ;;
	FreeBSD|OpenBSD)
	    doOpenBSD "$_type" "$_value"
	    ;;
	SunOS)
	    doSunOS "$_type" "$_value"
	    ;;
	*)
	    printERR $LINENO $BASH_SOURCE 1  "OS:\"$MYOS\" is not supported."
	    gotoHell 1
	    ;;
    esac
}



#FUNCBEG###############################################################
#NAME:
#  netGetBondSlaves
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Checks and lists SLAVE interfaces to a bonding master.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: true
#    1: false
#  VALUES:
#    space-seperated-list-of-slaves
#FUNCEND###############################################################
function netGetBondSlaves () {
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    case ${MYOS} in
	Linux);;
	*)  printWNG 2 $LINENO $BASH_SOURCE 2  "$FUNCNAME:OS=${MYOS} not yet supported";
	    return 1;
	    ;;
    esac
    if ! netCheckIsBonding $1 ;then
	return 1;
    fi

    local _myBond="/sys/class/net/$1/bonding/slaves";
    if [ ! -e "$_myBond" ];then
	printERR $LINENO $BASH_SOURCE 1  "Can not evaluate bonding slaves:$1 => \"$_myBond\"."
	gotoHell 1
    fi
    local _myIfs=`cat $_myBond`
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:$1=<${_myIfs}>"
    echo -e "$_myIfs"
}




#FUNCBEG###############################################################
#NAME:
#  netGetSSHPORTlst
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Treats any possible interface with each assigned port.
#  The assignement of multiple ports permutated to multiple interfaces 
#  is currently supported OpenSSH (only???).
#
#  The following is valid in any combination and number:
#    m* Port <#port>
#    n* Listenaddress <ip-address>
#    r* Listenaddress <ip-address>:<#port>
#
#
#EXAMPLE:
#
# 1.)
#    Port 22
#    Port 4444
#    Listenaddress 192.168.1.71:2222
#    Listenaddress 192.168.1.71:3333
#    Listenaddress 192.168.1.71
#
#    The result is:
#
#      192.168.1.71:22+2222+3333+4444
#
# 2.)
#    Port 22
#    Port 4444
#    Listenaddress 192.168.1.71:2222
#    Listenaddress 192.168.1.71:3333
#
#    The result is:
#
#      192.168.1.71:2222+3333
#
#      22+4444 are not accesible
#
# 3.)
#    Port 4444
#    Listenaddress 192.168.1.71:2222
#    Listenaddress 192.168.1.71:3333
#    Listenaddress 192.168.1.71
#
#    The result is:
#
#      192.168.1.71:2222+3333+4444
#
#      22 is not accesible
#
#
#
#PARAMETERS:
#  $1: IP address of IF. If given the full range of possible 
#
#GLOBALS:
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    listOfPorts="<#port0>[-<#port1>][-<#port2>]..."
#
#
#FUNCEND###############################################################
function netGetSSHPORTlst () {
    local _IP=;
    doDebug $S_LIB $D_BULK $LINENO $BASH_SOURCE
    local D=$?

    if [ -z "${1}" ];then
	return 1
    fi

    if [ -r "/etc/ssh/sshd_config" ];then
	_IP=`cat "/etc/ssh/sshd_config"|awk -v ifaddr="${1}" -v d=$D  -f ${_myLIBNAME_BASE_network}/netGetSSHPORTlst.awk`
    fi

    #
    #4CYGWIN-default
    if [ -r "/etc/sshd_config" ];then
	_IP=`cat "/etc/sshd_config"|awk -v ifaddr="${1}" -v d=$D  -f ${_myLIBNAME_BASE_network}/netGetSSHPORTlst.awk`
    fi

    echo ${_IP##* }
}




#FUNCBEG###############################################################
#NAME:
#  netGetDefaultGW
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Returns default GW.
#
#EXAMPLE:
#
#PARAMETERS:
#
#OUTPUT:
#  RETURN:
#    0: true
#    1: false
#  VALUES:
#    space-seperated-list-of-slaves
#FUNCEND###############################################################
function netGetDefaultGW () {
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"

    #quick, for one only, but sufficient for now
    case $MYOS in
	Linux)
	    local _defaultgw=`${CTYS_ROUTE} -n|awk '$1~/^0.0.0.0$/{printf("%s=%s-",$2,$NF);}'`
	    ;;
	CYGWIN)
	    local _defaultgw=$(${CTYS_IFCONFIG} |awk -v d=$D -v id=0 -f ${_myLIBNAME_BASE_network}/netGetIFDGW-${MYOS}.awk);
	    ;;
	OpenBSD)
	    local _defaultgw=`${CTYS_ROUTE} -n show |awk '$1~/^default$/{printf("%s=%s-",$2,$NF);}'`
	    ;;
	FreeBSD|SunOS)
	    local _defaultgw=`${CTYS_ROUTE} -n get default |awk -F':' '/gateway/{printf("%s=%s-",$2,$NF);}'`
	    ;;
    esac
    _defaultgw=${_defaultgw// /};

    if [ -n "${_defaultgw#*-}" ];then
	ABORT=2
	printWNG 1 $LINENO $BASH_SOURCE $ABORT  "Multiple \"default-gateways\" are defined,"
	printWNG 1 $LINENO $BASH_SOURCE $ABORT  "be careful with that axe Eugene."
	printWNG 1 $LINENO $BASH_SOURCE $ABORT  "Refer to \"http://lartc.org\"."
	local _i11=;
	local _idx11=0;
	for _i11 in ${_defaultgw//-/ };do
	    printWNG 1 $LINENO $BASH_SOURCE $ABORT  "default-GW[$_idx11]=${_i11//=/ for }"
	    let _idx11++;
	done
	local _defaultgwif="${_defaultgw%%-*}";
	_defaultgwif="${_defaultgwif#*=}";
	_defaultgw="${_defaultgw%%=*}";
	printWNG 1 $LINENO $BASH_SOURCE $ABORT  "Use the first on '${_defaultgwif}' only:${_defaultgw}"
    fi
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:$_defaultgw=<${_defaultgw}>"
    _defaultgw="${_defaultgw%%=*}";

    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:$_defaultgw=<${_defaultgw}>"
    echo -e -n "$_defaultgw"
}



#FUNCBEG###############################################################
#NAME:
#  netGetNetName
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#  Returns the network name received by "host", else empty.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <source>
#      MACMAP
#        Internal macmap.fdb-file-database only.
#      HOST
#        The UNIX-command "host"
#      BOTH
#        Both: 1.MACMAP (if failes)-> 2.HOST
#
#  $2: HOST,BOTH: <tcp-ip-address>
#      MACMAP:    <tcp-ip-address>|<MAC-address>
#
#OUTPUT:
#  RETURN:
#    0: conversion successfull
#    1: failed
#  VALUES:
#    space-seperated-list-of-slaves
#FUNCEND###############################################################
function netGetNetName () {
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local _mode=;
    case "${1}" in
	"MACMAP")_mode=${1};shift;;
	"HOST")_mode=${1};shift;;
	"BOTH")_mode=${1};shift;;
	*)_mode="BOTH";;
    esac
    local _myHost0=${1};
    local _ret=;

    function getHOST () {
	local _myHost0=${1};
	local _ret=;
	_myHost0=`callErrOutWrapper $LINENO $BASH_SOURCE host ${_myHost0}`
	_ret=$?;
	printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myHost0=${_myHost0}"
	if [ $_ret -ne 0 ];then
	    return 1
	fi
	local _myHost="${_myHost0%% *}";
	if [ "${_myHost//arpa/}" != "${_myHost}" ];then
	    _myHost="${_myHost0##* }";
	fi

	if [ -z "${_myHost}" ];then
	    return 1
	fi
	echo -n -e "${_myHost}"
    }

    function getMACMAP () {
	local _myHost0=${1};
	local _ret=;
	if [ "${_mode}" == MACMAP -o ${DBG} -eq $D_BULK ];then
	    _myHost0=`${MYLIBEXECPATH}/ctys-macmap.sh ${C_DARGS} -n "${_myHost0}"`;
	else
	    _myHost0=`${MYLIBEXECPATH}/ctys-macmap.sh ${C_DARGS} -n "${_myHost0}" 2>/dev/null`;
	fi
	printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_myHost0=${_myHost0}"

	if [ -z "$_myHost0" ];then
	    return 1
	fi
	echo -n -e "${_myHost}"
    }

    local _result=;
    case "${_mode}" in
	"MACMAP")_result=`getMACMAP ${_myHost0}`;;
	"HOST")_result=`getHOST ${_myHost0}`;;
	"BOTH")_result=`getMACMAP ${_myHost0}`;
	    if [ -z "$_result" ];then 
		_result=`getHOST ${_myHost0}`;
	    fi
	    ;;
    esac

    if [ -z "${_result}" ];then
	return 1;
    fi
    echo -n -e "${_result}"

return
}



#FUNCBEG###############################################################
#NAME:
#  netWaitForPing
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <target-to-poll>
#  $2: [<#trials>]
#  $3: [<timeout-before-next-trial>]
#
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#FUNCEND###############################################################
function netWaitForPing () {
    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local _target=$1;shift
    local _trials=$1;shift
    local _timeout=$1;shift
    
    _trials=${_trials:-$CTYS_PING_ONE_MAXTRIAL};
    _timeout=${_timeout:-$CTYS_PING_ONE_WAIT};

    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:_trials  =$_trials"
    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:_timeout =$_timeout"
    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:_target  =$_target"
    if [ -z "$_target" ];then
	sleep ${_timeout};
	printERR $LINENO $BASH_SOURCE 1  "$FUNCNAME:Missing target for ping."
	printERR $LINENO $BASH_SOURCE 1  "$FUNCNAME:Cannot poll, terminate wait."
	return 1
    fi

    local i1=0;
    while ((_trials>i1));do
	printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:trial-ping:$i1"
	callErrOutWrapper $LINENO $BASH_SOURCE "ping -c 1 ${_target}" >/dev/null
	[ $? -eq 0 ]&&break;
	sleep ${_timeout:-1};
	((i1++));
    done
    if((i1<_trials));then local _ret=0;else local _ret=1;fi
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:result:$_ret"
    return $_ret
}



#FUNCBEG###############################################################
#NAME:
#  netWaitForSSH
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <target-to-poll>
#  $2: [<#trials>]
#  $3: [<timeout-before-next-trial>]
#  $4: [<ssh-user>]
#  $5: [<ssh-opt>]
#
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#FUNCEND###############################################################
function netWaitForSSH () {
    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    local _target=$1;shift
    local _trials=$1;shift
    local _timeout=$1;shift
    local _sshuser=$1;shift
    local _sshopts=$1;shift
    
    _trials=${_trials:-$CTYS_SSHPING_ONE_MAXTRIAL};
    _timeout=${_timeout:-$CTYS_SSHPING_ONE_WAIT};
    _sshuser=${_sshuser:-$USER};
    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:_target  =$_target"
    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:_trials  =$_trials"
    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:_timeout =$_timeout"
    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:_sshuser =$_sshuser"
    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:_sshopts =$_sshopts"
    if [ -z "$_target" ];then
	sleep ${_timeout};
	printERR $LINENO $BASH_SOURCE 1  "$FUNCNAME:Missing target for sshping."
	printERR $LINENO $BASH_SOURCE 1  "$FUNCNAME:Cannot poll, terminate wait."
	return 1
    fi

    local i1=0;
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_sshuser=$_sshuser"
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:_target =$_target"
    while ((_trials>i1)) ;do
	printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:trial-ssh:$i1"
#	callErrOutWrapper $LINENO $BASH_SOURCE "ssh ${_sshuser:+ -l $_sshuser} ${_target} echo " >/dev/null
	ssh ${_sshopts} ${_sshuser:+ -l $_sshuser} ${_target} echo  2>/dev/null >/dev/null
	[ $? -eq 0 ]&&break;
	sleep ${_timeout:-1};
	((i1++));
    done
    if((i1<_trials));then local _ret=0;else local _ret=1;fi
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:result:$_ret"
    return $_ret
}




#FUNCBEG###############################################################
#NAME:
#  netIsEqualIP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Compares two arbitrary formatted TCP/IP addresses.
#
#  - decimal dotted-numerical
#  - dns, without domain
#  - dns, with domain
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <address0>
#  $2: <address1>
#
#OUTPUT:
#  RETURN:
#    0: OK - equal
#    1: NOK- different
#  VALUES:
#FUNCEND###############################################################
function netIsEqualIP () {
    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    
    if [ "$1" == "$2" ];then
	return 0;
    fi

    local buf=`host $1`
    buf0=${buf%% *}
    buf1=${buf##* }
    if [ "$buf0" == "$2" -o "$buf1" == "$2" ];then
	return 0;
    fi

    local buf=`host $2`
    buf0=${buf%% *}
    buf1=${buf##* }
    if [ "$buf0" == "$1" -o "$buf1" == "$1" ];then
	return 0;
    fi
    return 1;
}



#FUNCBEG###############################################################
#NAME:
#  netGetHostIP
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Encapsulates primarily the call of gethostip.
#
#  This particularly ensures operability in unmanaged networks by 
#  evaluating the file databases.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <dns-hostname|dotted-ip-address>
#
#OUTPUT:
#  RETURN:
#    0: OK - equal
#    1: NOK- different
#  VALUES:
#    Existing IP-address within the name databases.    
#
#FUNCEND###############################################################
function netGetHostIP () {
    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"
    
    local ret=0;
    local inp=$1

    if [ -z "$inp" ];then
	return 1;
    fi

    local myResolv=FILE
    local myHosts=/etc/hosts
    if [ ! -e "$myHosts" ];then myHosts="";myResolv="";fi

    #special gethostip
    which gethostip >/dev/null 2>/dev/null
    if [ $? -eq 0 ];then
	gethostip "$inp" >/dev/null 2>/dev/null
	ret=$?;
	if [ $ret -eq 0 ];then
	    local myAddr=$(gethostip "$inp"|awk '{print $2}');
	    if [ -n "$myAddr" ];then
		local myResolv=GETHOSTIP
	    fi
	fi
    fi

    #additional specials
    if [ -z "$myAddr" ];then
	case $MYOS in
	    CYGWIN)
		myAddr=$(${CTYS_NSLOOKUP} "$1" |awk -F':'  -v d=$D -v h="$inp"  '$2~h{x=1;}x==1&&/Address/{x=2;gsub(" ","",$2);printf("%s",$2);}');
		if [ -n "$myAddr" ];then
		    myResolv=CYGWIN
		else
		    ret=1;
		fi
		;;
	esac
    fi

    #last chance
    case $myResolv in
	CYGWIN)
	    echo -n "$myAddr"
	    ;;
	GETHOSTIP)
	    echo -n "$myAddr"
	    ;;
	FILE)
	    local myAddr=$(cat $myHosts|awk '
              {gsub("#.*$","");}
              {gsub("^[^:]*:.*:.*$","");}
              $1~/^ *'"$inp"'/{print $2}
              $0~/'"$inp"'/&&$1!~/^ *'"$inp"'/{print $1}
              ' )
	    echo -n "$myAddr"
	    ;;
	*)
	    ret=1
	    ;;
    esac

    return $ret;
}



#FUNCBEG###############################################################
#NAME:
#  netWorkaroundRestoreBonding
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  This is a validation of an bond interface for broken implementations
#  leaving of members in state down
#
#  ->e.g. vde-2.2.3 - vde_switch
#    when chown on mngmt-unix-socket
#
#  Any missing member and the bond interface itself are set to up,
#  no further configuration is performed - hopefully suffices.
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <bonding-interface>
#
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#
#FUNCEND###############################################################
function netWorkaroundRestoreBonding () {
    local _interface=$1;
    printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:\$@=$@"


    #some behave very individual, let's do te workaround
    if netCheckIsBonding $_interface ; then
	local xx=`netGetBondSlaves $_interface`;
        local _ret=0;
	local _react=;

	sleep ${NET_WAIT_BOND_WORKAROUND:-10}

	for ifx in $xx;do
	    if ! netCheckIfIs UP "${ifx}" 20;then 
		printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:RECOVER-BOND-IF:${_interface}(${ifx})"
		_react="${_react} ${ifx}"
		let _ret++;
	    fi
	done
	if [ $_ret -eq 0 ];then
	    if  netCheckIfIs UP "${_interface}" 20;then 
		printDBG $S_LIB ${D_UID} $LINENO $BASH_SOURCE "$FUNCNAME:No action for:${_interface}(${xx})"
		return
	    fi
	fi
	printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "$FUNCNAME:re-activation of bonding-slaves for:${_interface}(${_react})"

	local ifx=;
	checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL  CTYS_IFCONFIG $_interface down
	netCheckIfIs DOWN "${_interface}" 20
	
	for ifx in $xx;do
	    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL  CTYS_IFCONFIG $ifx down
	    netCheckIfIs DOWN "${ifx}" 20
	done
        sleep 2
	for ifx in $xx;do
	    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL  CTYS_IFCONFIG $ifx up
	    netCheckIfIs UP "${ifx}" 20
	done
	checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL  CTYS_IFCONFIG $_interface up
	netCheckIfIs UP "${_interface}" 20


	netClearRoute INTERFACE $_interface
    fi
}

#FUNCBEG###############################################################
#NAME:
#  netCreateBridge
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Creates an operational bridge including address and routing transfer.
#
#
#EXAMPLE:
#
#PARAMETERS:
#  $1  KEEPIP|CLEARIP
#      KEEPIP(default)
#        IP address remains on bridged IF
#      CLEARIP
#        IP address on IF is removed
#   REMARK:
#        Not yet implemented, currently the routing is transferred only
#
#  $2: <bridge>
#  $3: <interface>
#
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#
#FUNCEND###############################################################
function netCreateBridge () {
    local _bridge=${2}
    local _interface=${3}

    printINFO 1 $LINENO $BASH_SOURCE ${ABORT} "CREATE:new bridge=${_bridge} and exchange with interface:${_interface}"

    #not performance critical
    local _ip=$(netGetIP ${_interface}||echo "");

    local _nm=$(netGetMask ${_interface}||echo "");
    local _bc=$(netGetBroadcast ${_interface}||echo "");

    if [ -z "$_ip" ];then
	ABORT=1
	if((DBG>0));then
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Cannot fetch IP(${_interface})"
	else
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot fetch IP(${_interface})"
	fi
	gotoHell ${ABORT}  
    fi

    if [ -z "$_bc" ];then
	ABORT=1
	if((DBG>0));then
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Cannot fetch broadcast(${_interface})"
	else
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot fetch broadcast(${_interface})"
	fi
	gotoHell ${ABORT}  
    fi

    if [ -z "$_nm" ];then
	ABORT=1
	if((DBG>0));then
	    printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Cannot fetch netmask(${_interface})"
	else
	    printERR $LINENO $BASH_SOURCE ${ABORT} "Cannot fetch netmask(${_interface})"
	fi
	gotoHell ${ABORT}  
    fi

    if [ -n "$SSH_TTY" ];then
	if [ -z "$_force" ];then
	    ABORT=0
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "You are executing the creation of a bridge via "
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "a network connection. This will probably disconnect"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "your session for a short time or longer, maybe"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "forever."
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Thus call \"${MYCALLNAME}\" with the \"-f\" option"
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "if you really want to proceed."
	    printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "Else choose a local user - with local storage."
	    gotoHell ${ABORT};
 	fi
    fi

#This might not occur:
#     if netCheckIsXen ; then
# 	${MYLIBEXECPATH}/ctys-xen-network-bridge.sh ${C_DARGS} start bridge="${_bridge}" netdev="${_interface}"
# 	return
#     fi

    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL CTYS_BRCTL addbr $_bridge
    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL CTYS_BRCTL stp   $_bridge on
    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL CTYS_BRCTL setfd $_bridge ${BRIDGE_FWDELAY:-0}

    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL CTYS_SYSCTL -w "net.bridge.bridge-nf-call-arptables=0"
    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL CTYS_SYSCTL -w "net.bridge.bridge-nf-call-ip6tables=0"
    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL CTYS_SYSCTL -w "net.bridge.bridge-nf-call-iptables=0"

    #disable ipv6 by small mtu refer to xen-net-script
    mtu=$(checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL CTYS_IP link show ${_bridge} | sed -n 's/.* mtu \([0-9]\+\).*/\1/p')
    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL CTYS_IP link set ${_bridge} mtu 68
    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL CTYS_IP link set ${_bridge} up
    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL CTYS_IP link set ${_bridge} mtu ${mtu:-1500}

    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL CTYS_IFCONFIG $_bridge up
    netTransferAddr  "${_interface}" "${_bridge}" >/dev/null
    netTransferRoute "${_interface}" "${_bridge}" >/dev/null
    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL CTYS_BRCTL addif $_bridge $_interface
    netWorkaroundRestoreBonding $_interface
}



#FUNCBEG###############################################################
#NAME:
#  netCancelBridge
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Cancels a bridge including address and routing transfer to the interface.
#
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <bridge>
#
#OUTPUT:
#  RETURN:
#    0: OK
#    1: NOK
#  VALUES:
#
#FUNCEND###############################################################
function netCancelBridge () {
    local _bridge=${1}
    printINFO 2 $LINENO $BASH_SOURCE 0 "${FUNCNAME}:bridge:$_bridge == $_mybridge"

    if [ -z "${_bridge}" ];then
	ABORT=1;
	printERR $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Missing option bridge"
	return ${ABORT}  
    fi

    #not performance critical
    local _ip=`netGetIP ${_bridge}`;
    local _nm=`netGetMask ${_bridge}`;
    local _bc=`netGetBroadcast ${_bridge}`;

    #back transform network interface
    #could have been done before, anyhow... should be one only now.
    for i in `netListBridgePorts $_bridge`;do
	checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL  CTYS_BRCTL  delif $_bridge $i 
	netCheckIsBonding $i >/dev/null;
	if [ $? -eq 0 ];then
	    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL  CTYS_IFCONFIG $i down
	    netCheckIfIs DOWN "${i}" 20 >/dev/null
	    local ifx=;
	    for ifx in `netGetBondSlaves $i`;do
		checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL  CTYS_IFCONFIG $ifx up
		netCheckIfIs UP "${ifx}" 20 >/dev/null
	    done
	    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL  CTYS_IFCONFIG $i up 
	    netCheckIfIs UP "${i}" 20 >/dev/null
	fi
    done
    netClearRoute INTERFACE $_interface >/dev/null
    netTransferRoute "${_bridge}" "${_interface}" >/dev/null

    #remove bridge
    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL  CTYS_IFCONFIG $_bridge down 
    checkedSetSUaccess retry norootpreference "${_myHint}" BRCTLCALL  CTYS_BRCTL  delbr $_bridge 
}


#FUNCBEG###############################################################
#NAME:
#  netCalcMask
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1  IP address
#
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function netCalcMask () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME"
    local _ip=$1;
    local _clsdec=${_ip%%.*};
    local _mask=;

    if((_clsdec<128));then
	_mask=255.0.0.0;
    fi
    if((_clsdec>127&&_clsdec<192));then
	_mask=255.255.0.0;
    fi
    if((_clsdec>191&&_clsdec<224));then
	_mask=255.255.0.0;
    fi
    if((_clsdec>223&&_clsdec<240));then
	_mask=255.255.255.0;
    fi
    printDBG $S_LIB ${D_MAINT} $LINENO $BASH_SOURCE "$FUNCNAME:netmask=$_mask"
    echo -n $_mask
}


#FUNCBEG###############################################################
#NAME:
#  netGetFirstFreePort
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Gets the first free port above a given base, thus multiple regions
#  could be managed
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <MIN>
#  $2: [<MAX>]
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    <first-port>
#
#FUNCEND###############################################################
function netGetFirstFreePort () {
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:CALL=<${*}>"
    local MIN=${1:-$NET_PORTRANGE_MIN};
    local MAX=${2:-$NET_PORTRANGE_MAX};
    [ -z "$MAX" ]&&let MAX=MIN+1000;
    local NET_PORTSEED=${NET_PORTSEED:-100};
    local _seed=$((RANDOM%NET_PORTSEED));
    doDebug $S_LIB  ${D_MAINT} $LINENO $BASH_SOURCE
    local D=$?

    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:MIN=${MIN} MAX=${MAX} seed=${_seed}"
    case ${MYOS} in
	Linux)
	    local localClientAccess=`${CTYS_NETSTAT} -n -l -t|awk -v d="${D}" -v min="${MIN}" -v max="${MAX}" -v seed="${_seed}" -f ${_myLIBNAME_BASE_network}/netGetFirstFreePort-${MYOS}.awk`
	    ;;
	CYGWIN)
	    local localClientAccess=`${CTYS_NETSTAT} -n -p TCP -a |awk -v d="${D}" -v min="${MIN}" -v max="${MAX}" -v seed="${_seed}" -f ${_myLIBNAME_BASE_network}/netGetFirstFreePort-${MYOS}.awk`
	    ;;
	FreeBSD|OpenBSD)
	    local localClientAccess=`${CTYS_NETSTAT} -n -l -t|awk -v d="${D}" -v min="${MIN}" -v max="${MAX}" -v seed="${_seed}" -f ${_myLIBNAME_BASE_network}/netGetFirstFreePort-${MYOS}.awk`
	    ;;
	SunOS)
	    local localClientAccess=`${CTYS_NETSTAT} -n -l -t|awk -v d="${D}" -v min="${MIN}" -v max="${MAX}" -v seed="${_seed}" -f ${_myLIBNAME_BASE_network}/netGetFirstFreePort-${MYOS}.awk`
	    ;;
    esac
    printDBG $S_LIB ${D_BULK} $LINENO $BASH_SOURCE "$FUNCNAME:localClientAccess=<${localClientAccess}>"
    echo -n -e "${localClientAccess}";
}


#FUNCBEG###############################################################
#NAME:
#  netAdjustMAC
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#  Gets the first free port above a given base, thus multiple regions
#  could be managed
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: <MAC-label>
#  $2: <arbitrary-MAC-raw-format>
#
#OUTPUT:
#  RETURN:
#  VALUES:
#    <standard-MAC-format>
#    Currently no case-adaption
#
#FUNCEND###############################################################
function netAdjustMAC () {
    if [ -z "${MAC0#??:??:??:??:??:??}" ];then
	echo -n "$2"
	return
    fi
    local _x=$(echo "$2"|sed '
      s/\([0-9A-Fa-f][0-9A-Fa-f]\)\([0-9A-Fa-f][0-9A-Fa-f]\)/\1:\2/g
      s/\([0-9A-Fa-f][0-9A-Fa-f]\)\([0-9A-Fa-f][0-9A-Fa-f]\)/\1:\2/g
      '
    )
    if [ -n "${_x#??:??:??:??:??:??}" ];then
	ABORT=127
	printERR $LINENO $BASH_SOURCE ${ABORT} "Erroneous MAC format:${1}=${2}"
	gotoHell ${ABORT}
    fi
    echo -n "$_x"
}
