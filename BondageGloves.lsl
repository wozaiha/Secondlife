integer locked;
integer binded;
integer public;
integer mittened;
integer rlvon;
list owner;
integer TOLOCK=0;
integer TOBIND=1;
integer TOMITTEN=2;
    list locks=[];
    list mittens=[];
    list binds=[];
    list bam=[];
integer ani;    
integer handle;    

CheckLockPrim(){
    integer n=2;
    string name;
    for (;n<=llGetNumberOfPrims();n++){
        name=(string)llGetObjectDetails(llGetLinkKey(n),[OBJECT_NAME]);
        if (name=="Lock") locks+=n;
        if ((name=="Gchain")) binds+=n;
        if ((name=="Mitten")|| (name=="Mbuckle"))  mittens+=n;
        if ((name=="Mchain")) bam+=n;
        }
    }


Core(integer what,integer todo,key id){
    integer n;
    if (what==TOLOCK) {
        locked=todo;
         for (n=0;n<llGetListLength(locks);n++){
            llSetLinkAlpha(llList2Integer(locks,n),todo,ALL_SIDES);
        }
    }
        else if (what==TOBIND) {
            binded=todo;
            ani=what;
            for (n=0;n<llGetListLength(binds);n++){
                llSetLinkAlpha(llList2Integer(binds,n),todo,ALL_SIDES);
            }
            if (mittened) for (n=0;n<llGetListLength(bam);n++){
                llSetLinkAlpha(llList2Integer(bam,n),todo,ALL_SIDES);
            }
            if (todo) llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
                else llStopAnimation("KAwithoutmiten");
        }
        else if (what==TOMITTEN) {
            mittened=todo;
            ani=what;
            for (n=0;n<llGetListLength(mittens);n++){
                llSetLinkAlpha(llList2Integer(mittens,n),todo,ALL_SIDES);
            }
            if (binded) for (n=0;n<llGetListLength(bam);n++){
                llSetLinkAlpha(llList2Integer(bam,n),todo,ALL_SIDES);
            }
            if (todo) llRequestPermissions(llGetOwner(), PERMISSION_TRIGGER_ANIMATION);
            else llStopAnimation("KAmitten");
        }
        
            llDialog(id,"Please Choose.",butt(0),-3434343);
            handle=llListen(-3434343,"",id,"");
            llSetTimerEvent(60);
}

RLVCore(){

}

OwnerCore(){

}
list butt(integer n){
     list button=[];
    if (n == 0){
        if (locked) button+=["Unlock"]; else button+=["Lock"];
        if (binded) button+=["Unbind"]; else button+=["Bind"];
        if (mittened) button+=["Unmitten"]; else button+=["Mitten"];
		button+=["Access"];
        return button;
    }
     return button;
}

default
{
    state_entry(){
        CheckLockPrim();
        }
    touch_start(integer detected){
        llDialog(llDetectedKey(0),"Please Choose.",butt(0),-3434343);
        handle=llListen(-3434343,"",llDetectedKey(0),"");
        llSetTimerEvent(60);
    }
    listen(integer channel, string name, key id, string message){
        llSetTimerEvent(0);
        llListenRemove(handle);
        if (channel != -3434343) jump break;
        if (message == "Lock") Core(TOLOCK,1,id);
        else if (message == "Unlock") Core(TOLOCK,0,id);
        else if (message == "Bind") Core(TOBIND,1,id);
        else if (message == "Unbind") Core(TOBIND,0,id);
        else if (message == "Mitten") Core(TOMITTEN,1,id);
        else if (message == "Unmitten") Core(TOMITTEN,0,id);
		else if (message == "Access") llMessageLinked(-1,999,"access menu",id);
		else if (message == "hide reset") llMessageLinked(-1,999,"reset",id);
        @break;
    }
    run_time_permissions(integer perm){
        if (perm & PERMISSION_TRIGGER_ANIMATION){
            if (ani == TOBIND) llStartAnimation("KAwithoutmiten");
            else if (ani == TOMITTEN) llStartAnimation("KAmitten");
            ani=0;
        }
    }
    changed(integer change){
        if (change & CHANGED_OWNER) llResetScript();
    }
	attach(key id){
		if (id == llGetOwner()) {if (locked) Core(TOLOCK,1,id); if (binded) Core(TOBIND,1,id); if (mittened) Core(TOMITTEN,1,id);}
			else if (id == NULL_KEY) /*    */;
	}
    timer(){
        llSetTimerEvent(0);
        llListenRemove(handle);
    }
}
