########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue.opensource@gmail.com
#MAINTAINER:   Arno-Can Uestuensoez - acue.opensource@gmail.com
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      Apache-2.0
#VERSION:      01_06_023
#
########################################################################
#
# Copyright (C) 2011 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################


#quick-hack for now...

A=$1
A0=${A%-*}
B0=${A#*-}

a0=${A0%.*.*.*}
a1=${A0%.*.*};a1=${a1#*.}
a2=${A0%.*};a2=${a2#*.*.}
a3=${A0##*.};

b0=${B0%.*.*.*}
b1=${B0%.*.*};b1=${b1#*.}
b2=${B0%.*};b2=${b2#*.*.}
b3=${B0##*.};

let 'x0=a0&b0' 'x1=a1&b1' 'x2=a2&b2' 'x3=a3&b3' 'y0=255^b0' 'y1=255^b1' 'y2=255^b2' 'y3=255^b3' 'z0=a0|y0' 'z1=a1|y1' 'z2=a2|y2' 'z3=a3|y3';

#echo $x0"."$x1"."$x2"."$x3;
#echo $y0"."$y1"."$y2"."$y3;
echo -n "$z0.$z1.$z2.$z3";

