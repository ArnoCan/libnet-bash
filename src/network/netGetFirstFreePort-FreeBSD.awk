#
#$Header: /home2/reps/cvs/proj/ctys/ctys-rt/src/lib/network/netGetFirstFreePort-FreeBSD.awk,v 1.2 2011/12/05 15:15:55 acue Exp $
#
########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a10
#
########################################################################
#
# Copyright (C) 2007 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
    gsub("^[0-9.]*:+","",$4);
}

$4>min&&$4<max{
    idx=$4-min;
    chk[idx]=$4;
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
