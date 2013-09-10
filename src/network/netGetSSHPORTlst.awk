#
#$Header: /home2/reps/cvs/proj/ctys/ctys-rt/src/lib/network/netGetSSHPORTlst.awk,v 1.2 2011/12/05 15:15:55 acue Exp $
#
#!/bin/bash

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
function perror(inp){
      if(!d){
          print line ":" inp | "cat 1>&2"
      }
}


BEGIN{
    perror("ifaddr=<"ifaddr">");
    pi=0;   plst[1]="";
    ai=0;   alst[1]="";
    pai=0;  palst[1]="";
    all=0;
    out="";
    line=0;
}

{line++;}

$1~/^ *ListenAddress/&&$2~"0.0.0.0"{
    perror("match=<"$0">");
    all=1;
    next;
}

$1~/^ *ListenAddress/&&$2~ifaddr":"{
    perror("match=<"$0">");
    palst[pai++]=$2;
    next;
}

$1~/^ *ListenAddress/&&$2~ifaddr{
    perror("match=<"$0">");
    alst[ai++]=$2;#doesn't hurt
    next;
}

$1~/^ *Port/{
    perror("match=<"$0">");
    plst[pi++]=$2;
    next;
}

END{
    #collect all explicit ports
    for(i=0;i<pai;i++){
    perror("i=<"i">");
    perror("palst[i]=<"palst[i]">");
	gsub("[^:]*:","",palst[i]);
    perror("palst[i]=<"palst[i]">");
	if(i==0){out=palst[i];}
        else{out=out"-"palst[i];}
    perror("out=<"out">");
    }
    perror("out=<"out">");
    if(alst[0]!=""||all==1){
            #collect all floating ports
	    for(i=0;i<pi;i++){
  		if(i==0&&out==""){out=plst[i];}
 	        else{out=out"-"plst[i];}
	    }
    }
    perror("out=<"out">");
    printf("%s",out);
}
