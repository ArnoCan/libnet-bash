#
#$Header: /home2/reps/cvs/proj/ctys/ctys-rt/src/lib/network/netGetIFlst-OpenBSD.awk,v 1.2 2011/12/05 15:15:55 acue Exp $
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
# Copyright (C) 2007,2008 Arno-Can Uestuensoez (UnifiedSessionsManager.org)
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
    size=split(y,A,"");
    for(i=size;i>0;i--){
        if(A[i]=="f"||A[i]=="F")m=15;
        else if(A[i]=="e"||A[i]=="E")m=14;
        else if(A[i]=="d"||A[i]=="D")m=13;
        else if(A[i]=="c"||A[i]=="C")m=12;
        else if(A[i]=="b"||A[i]=="B")m=11;
        else if(A[i]=="a"||A[i]=="A")m=10;
        else m=A[i];
        a=a+power16(size-i)*m;
    }
    return a;
}

function hexip (ip) {
    size=split(ip,B,"");
    w="";
    for(k=size;k>2;k-=2){
        z=B[k-1]""B[k];
        q=polynom16(z);
        w=q"."w;
    }
    gsub(".$","",w);
    return w;
}


function addIfDat() {
    if(getif==2||s=="WITHMAC"||s=="ALL"){
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
    ptrace("scope =<"s">");
    ptrace("format=<"f">");
}

$2~/flags=/{
    #test for now, IF without IP, mainly for protocol analysers, and WoL-Only-IFs
    if(getif!=0){
        addIfDat();
    }
    cache=$1;
}

$1~/lladdr/{
    getif=1; 
    curmac=$2;
}

$1!~/inet6/&&$1~/inet/{
    if(getif==1){
        curip=$2;
        if(s=="WITHIP"&&curip~/^$/){
            ptrace("Ignored:"$2);
            getif=0;            
        }        
        curmask=hexip($4);
        if(s=="WITHIP"&&curmask~/^$/){
            ptrace("Ignored:"$4);
        }        

        curbcst=$6;
        if(s=="WITHIP"&&curbcst~/^$/){
            ptrace("Ignored:"$6);
        }        
        gsub(":","",cache);
        curname=cache;
        if(s=="WITHIP"&&curname~/^$/){
            ptrace("Ignored:"curname);
        }        
        if(getif!=0)getif=2;
    }
}
getif==2{
    addIfDat();
}

    
END{
    print iflst;
}
