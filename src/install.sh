########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue.opensource@gmail.com
#MAINTAINER:   Arno-Can Uestuensoez - acue.opensource@gmail.com
#SHORT:        ctys
#LICENCE:      Apache-2.0
#VERSION:      01_11_007
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
#
#DESCRIPTION:
#     A draft split-off from:
#     	www.unifiedsessionsmanager.org
########################################################################




#
#Execution anchor
MYCALLPATHNAME=$0
MYCALLNAME=`basename $MYCALLPATHNAME`
MYCALLNAME=${MYCALLNAME%.sh}
MYCALLPATH=`dirname $MYCALLPATHNAME`


BINDIR="${BINDIR:-$HOME/bin}/bootstrap"
if [ ! -d "$BINDIR" ];then
	echo "Make:BINDIR=$BINDIR"
	mkdir -p "$BINDIR"
fi 

LIBDIR="${LIBDIR:-$HOME/lib}"
if [ ! -d "$LIBDIR" ];then
	echo "Make:LIBDIR=$LIBDIR"
	mkdir -p "$LIBDIR"
fi 

BOOTSTRAP="${BOOTSTRAP:-$BINDIR}/bootstrap"
if [ ! -d "$BOOTSTRAP" ];then
	echo "Make:BOOTSTRAP=$BOOTSTRAP"
	mkdir -p "$BOOTSTRAP"
fi 
for i in bootstrap/*;do
	echo "->${i}"
	cp -r ${i} ${BOOTSTRAP}
done

echo "->libconsole.sh $LIBDIR"
cp libconsole.sh $LIBDIR

