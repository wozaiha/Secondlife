
integer PRIM=2;
integer FACE=2;
integer SELF=0;
integer OWNER=1;

string Owner(){
    return llList2String(llGetLinkMedia(PRIM,FACE,[PRIM_MEDIA_WHITELIST]),0);
}
integer Ownself(){
    return llList2Integer(llGetLinkMedia(PRIM,FACE,[PRIM_MEDIA_WHITELIST_ENABLE]),0);
}

























default {

}
