integer PRIM=2;
integer FACE=2;
integer SELF=0;
integer OWNER=1;

integer handle;
integer what;


string Owner(){
    return llList2String(llGetLinkMedia(PRIM,FACE,[PRIM_MEDIA_WHITELIST]),0);
}
integer Ownself(){
    return llList2Integer(llGetLinkMedia(PRIM,FACE,[PRIM_MEDIA_WHITELIST_ENABLE]),0);
}


Add(integer target,key id){
	if	(id) ; else return;
    if (target==OWNER)
        if (id != llGetOwner()){
            string str=Owner();
            if (llStringLength(str)>100) {
                //Message user;
                return;
            }
            if (llSubStringIndex(str,(string)id)>=0) return;
                else {
                    str=(string)id+","+str;
                    llSetLinkMedia(PRIM,FACE,[PRIM_MEDIA_WHITELIST,str]);
                }
            }
        else llSetLinkMedia(PRIM,FACE,[PRIM_MEDIA_WHITELIST_ENABLE,1]);
}

Del(integer target,key id){
    if (target==SELF){
        llSetLinkMedia(PRIM,FACE,[PRIM_MEDIA_WHITELIST_ENABLE,0]);
        return;
    }
    string str=Owner();
    if (target==OWNER){
        integer n=llSubStringIndex(str,(string)id);
        if (n<0) return;
        str=llDeleteSubString(str,n,n+36);
        llSetLinkMedia(PRIM,FACE,[PRIM_MEDIA_WHITELIST,str]);
    }
}

string Print(){
    string str="现在的Owner有：";
    list lis=llParseString2List(Owner(),[","],[]);
    if (llGetListLength(lis)==0) str="现在没有Owner。";
        else {
            integer n;
            for (n==0;n<llGetListLength(lis);n++)        str+="secondlife:///app/agent/" + llList2String(lis,n) + "/about,";
            str=llDeleteSubString(str,-1,-1)+"。";
        }
    if (Ownself()) str+="\n\n穿戴者：√";
        else str+="\n\n穿戴者：×";
    return str;
}

integer Check(key id,integer target){
    if (target==OWNER) {
    if ((llStringLength(Owner())==0) && (id == llGetOwner())) return 1;
        if (llSubStringIndex(Owner(),(string)id) > -1) return 1;
            else if ((Ownself()) && (id==llGetOwner())) return 1;
        else return 0;
    }
    return 0;
}

ShowMenu(key id){
    llDialog(id,Print(),["添加","删除"],-3434343);
    handle=llListen(-3434343,"",id,"");
}

Showadd(key id){
    llTextBox(id,"请输入目标UUID：",-3434343);
    handle=llListen(-3434343,"",id,"");
    what=1;
}

Showdel(key id){
    what=-1;
    list lis=llParseString2List(Owner(),[","],[]);
    list button=[];
    integer i;
    for (i==0;i<llGetListLength(lis);i++) button+=(string)i;
    if (Ownself()) button+="穿戴者";
    llDialog(id,Print(),button,-3434343);
    handle=llListen(-3434343,"",id,"");
}

default{
    link_message( integer sender_num, integer num, string str, key id ){
        if (Check(id,OWNER)) {
            if (str=="access menu")  ShowMenu(id);
                else if (str=="reset") {
                llClearLinkMedia(PRIM,FACE);
                llSetLinkMedia(PRIM,FACE,[PRIM_MEDIA_PERMS_INTERACT,PRIM_MEDIA_PERM_NONE]);
                llSetLinkMedia(PRIM,FACE,[PRIM_MEDIA_PERMS_CONTROL,PRIM_MEDIA_PERM_NONE]);
                llResetScript();
                }
        }
    }
    listen(integer channel,string name,key id,string msg){
        llListenRemove(handle);
        if (msg=="添加") Showadd(id);
            else if (msg=="删除") Showdel(id);
            else if (((key)msg!= NULL_KEY) && (what == 1)) {
                what=0;
                Add(OWNER,(key)msg);
                ShowMenu(id);
            }
            else if ((what == -1)) {
                if (msg=="穿戴者") Del(SELF,llGetOwner());
                else Del(OWNER,llList2Key(llParseString2List(Owner(),[","],[]),(integer)msg));
                ShowMenu(id);
            }
    }
}
