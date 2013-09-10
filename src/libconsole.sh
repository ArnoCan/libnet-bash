#!/bin/bash
#
#

#
#$Header$
#


########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue.opensource@gmail.com
#MAINTAINER:   Arno-Can Uestuensoez - acue.opensource@gmail.com
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      Apache-2.0
#VERSION:      01_02_007a17
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

_myLIBNAME_colors="${BASH_SOURCE}"
_myLIBVERS_colors="01.02.002c01"
libManInfoAdd "${_myLIBNAME_colors}" "${_myLIBVERS_colors}"


#assume for now ANSI/color support
case "$TERM" in
    xterm)TRM=0;;
    dtterm)TRM=0;;
    *)TRM=1;;
esac

#FUNCBEG###############################################################
#NAME:
#  termColorSet
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#
#EXAMPLE:
#
#PARAMETERS:
#  $1: foreground color:
#       30 black
#       31 red
#       32 green
#       33 yellow
#       34 blue
#       35 magenta
#       36 cyan
#       37 white
#
#  $2: background color:
#       40 black
#       41 red
#       42 green
#       43 yellow
#       44 blue
#       45 magenta
#       46 cyan
#       47 white
#      
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function termColorSet () {
    if [ ! "$TRM" ];then
	return
    fi
    local _col=;
    case $1 in
	0)_col=0;;
	30|black)_col=30;;
	31|red)_col=31;;
	32|green)_col=32;;
	33|yellow)_col=33;;
	34|blue)_col=34;;
	35|magenta)_col=35;;
	36|cyan)_col=36;;
	37|white)_col=37;;
	*)_col=0;printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Unknown foreground color:$1";;
    esac
    if [ "$_col" != 0 ];then
	echo -e -n "\033[${_col}m"
    fi 

    case $2 in
	0)_col=0;;
	40|black)_col=40;;
	41|red)_col=41;;
	42|green)_col=42;;
	43|yellow)_col=43;;
	44|blue)_col=44;;
	45|magenta)_col=45;;
	46|cyan)_col=46;;
	47|white)_col=47;;
	*)_col=0;printWNG 1 $LINENO $BASH_SOURCE ${ABORT} "${FUNCNAME}:Unknown background color:$2";;
    esac
    if [ "$_col" != 0 ];then
	echo -e -n "\033[${_col}m"
    fi 
}




#FUNCBEG###############################################################
#NAME:
#  termReset
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#EXAMPLE:
#PARAMETERS:
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function termReset () {
    if [ ! "$TRM" ];then
	return
    fi
    echo -e -n "\033[m"
}


#FUNCBEG###############################################################
#NAME:
#  termSetUnderline
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#EXAMPLE:
#PARAMETERS:
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function termSetUnderline () {
    if [ ! "$TRM" ];then
	return
    fi
    echo -e -n "\033[4m"
}


#FUNCBEG###############################################################
#NAME:
#  termSetBold
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#EXAMPLE:
#PARAMETERS:
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function termSetBold () {
    if [ ! "$TRM" ];then
	return
    fi
    echo -e -n "\033[1m"
}

#FUNCBEG###############################################################
#NAME:
#  termSetReverse
#
#TYPE:
#  bash-function
#
#DESCRIPTION:
#EXAMPLE:
#PARAMETERS:
#OUTPUT:
#  RETURN:
#
#  VALUES:
#
#FUNCEND###############################################################
function termSetReverse () {
    if [ ! "$TRM" ];then
	return
    fi
    echo -e -n "\033[7m"
}

