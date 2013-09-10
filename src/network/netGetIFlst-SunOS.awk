#
#$Header: /home2/reps/cvs/proj/ctys/ctys-rt/src/lib/network/netGetIFlst-SunOS.awk,v 1.2 2011/12/05 15:15:55 acue Exp $
#
########################################################################
#
#PROJECT:      Unified Sessions Manager
#AUTHOR:       Arno-Can Uestuensoez - acue@UnifiedSessionsManager.org
#MAINTAINER:   Arno-Can Uestuensoez - acue_sf1@users.sourceforge.net
#SHORT:        ctys
#CALLFULLNAME: Commutate To Your Session
#LICENCE:      GPL3
#VERSION:      01_06_001a13
#
########################################################################
#
# Copyright (C) 2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
#
########################################################################

function ptrace(inp){
      if(!d){
          print line ":" inp | "cat 1>&2"
      }
}

function power16 (x) {
    if(x==0)res=1;
    else if(x==1)res=16;
    else{
        res=16;
        for(j=1;j<x;j++){
            res=16*res
        }
    }
    return res;
}

function polynom16 (y) {
    a=0;
    size=length(y);
    ptrace("size=<"size">");
    for(i=size;i>0;i--){
        c=substr(y,i,1);
        if(c=="f"||c=="F")m=15;
        else if(c=="e"||c=="E")m=14;
        else if(c=="d"||c=="D")m=13;
        else if(c=="c"||c=="C")m=12;
        else if(c=="b"||c=="B")m=11;
        else if(c=="a"||c=="A")m=10;
        else m=c;
        ptrace("y("i")=<"c"> m=<"m">");
        a=a+power16(size-i)*m;
        ptrace("a=<"a">");
    }
    return a;
}

function hexip (ip) {
    ptrace("ip=<"ip">");
    size=length(ip);
    w="";
    for(k=size;k>0;k-=2){
        z=substr(ip,k-1,2);
        q=polynom16(z);
        w=q"."w;
    }
    ptrace("w=<"w">");
    gsub(".$","",w);
    return w;
}

function addIfDat() {
    if(getif==3||s=="WITHMAC"||s=="ALL"){
        if(curmac!~/^$/){
            if(f=="CONFIG"){
                iflst=iflst" "curmac"="curip"%"curmask"%"curname;
            }else{
                iflst=iflst" "curmac"="curip;
            }
        }
    }
   
    curmac="";
    curip="";
    curmask="";
    curname="";
    getif=0;
}


BEGIN{
    getif=0;
    iflst="";
    ptrace("netGetIFlst");
    ptrace("scope=<"s">");

    
}

{ptrace("display:"$0);}

/: *flags=/{
    #test for now, IF without IP, mainly for protocol analysers, and WoL-Only-IFs
    if(getif!=0){
        addIfDat();
    }
    if($1!="lo[0-9]*:"){ 
        getif=1;
        curname=$1;
        gsub(":","",curname);
        ptrace("Set:"curname);
    }else{        
        ptrace("Ignored:"$1);
    }
    next;
}

/inet /{
    if(getif==1){
        getif=2;
        curip=$2;
        ptrace("Fetch:"curip);
        if(s=="WITHIP"&&curip~/^$/){
            ptrace("Ignored(IP):"curname);
            getif=0;            
        }        
        curmask=hexip($4);
        ptrace("Fetch:"curmask);
        if(s=="WITHIP"&&curmask~/^$/){
            ptrace("Ignored(MASK):"curname);
        }        
        curbcst=$NF;
        ptrace("Fetch:"curbcst);
        if(s=="WITHIP"&&curbcst~/^$/){
            ptrace("Ignored(BCST):"curname);
        }        
    }
    next;
}

$1~/ether/{
    getif=3; 
    curmac=$2;
}

getif==3{
    addIfDat();
}

END{
    print iflst;
}
