#
#$Header: /home2/reps/cvs/proj/ctys/ctys-rt/src/lib/network/netGetFirstIF-CYGWIN.awk,v 1.2 2011/12/05 15:15:55 acue Exp $
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
    a0="";
    matched=0;
    complete=0;
    idx=0;
}
matched==0&&complete==0&&/^E.*[0-9]+"*:/{
    a0=$0;
    gsub("E[^0-9]*","",a0);
    gsub("[^0-9]*:","",a0);
    gsub("[^0-9]","",a0);
    idx=a0;
    matched=1;
}
matched==0&&complete==0&&/^E.*[0-9]*"*:/{
    a0=$0;
    gsub("E[^0-9]*","",a0);
    gsub("[^0-9]*:","",a0);
    gsub("[^0-9]","",a0);
    idx=1;
    matched=1;
    complete=1;
}
# matched==1&&complete==0&&/^[^A-Za-z]+IP-[^:]+: *[0-9.]+/{
#     complete=1;
# }
END{
    print idx;
}
