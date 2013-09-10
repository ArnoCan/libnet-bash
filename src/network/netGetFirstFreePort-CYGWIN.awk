#
#$Header: /home2/reps/cvs/proj/ctys/ctys-rt/src/lib/network/netGetFirstFreePort-CYGWIN.awk,v 1.2 2011/12/05 15:15:55 acue Exp $
#
########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_023
#
########################################################################
#
# Copyright (C) 2011 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

function ptrace(inp){
    if(!d){
        print line ":" inp | "cat 1>&2"
    }
}


BEGIN{
    ptrace("awk:getFirstFreeVNCPort");
    ptrace("min ="min);
    ptrace("max ="max);
    ptrace("seed="seed);
    chk[0]="";
}

{
    gsub("^[0-9.]*:+","",$2);
}

$2>min&&$2<max{
    idx=$2-min;
    chk[idx]=$2;
}

END{
    l=max-min;
    for(i=0;i<l;i++){
        if(chk[i]==""){
            if(seed==0){break;}
            seed--;
            ptrace("skip("seed")="i);
        }
    }
    if(i<max){
        ptrace("result="i);
        printf("%d",min+i);
    }else{
        ptrace("result exceeds maximum("max")="i);
    }
}
