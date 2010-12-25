{
*****************************************************************************
*                                                                           *
*  This file is part of the ZCAD                                            *
*                                                                           *
*  See the file COPYING.modifiedLGPL.txt, included in this distribution,    *
*  for details about the copyright.                                         *
*                                                                           *
*  This program is distributed in the hope that it will be useful,          *
*  but WITHOUT ANY WARRANTY; without even the implied warranty of           *
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.                     *
*                                                                           *
*****************************************************************************
}
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit commandline;
{$INCLUDE def.inc}
interface
uses sysinfo,strproc,UGDBOpenArrayOfPointer,UDMenuWnd,gdbasetypes,commandlinedef, sysutils,gdbase,oglwindowdef,
     memman,shared,log;
type
  GDBcommandmanager=object(GDBcommandmanagerDef)
                          CommandsStack:GDBOpenArrayOfGDBPointer;
                          ContextCommandParams:GDBPointer;
                          busy:GDBBoolean;

                          constructor init(m:GDBInteger);
                          function execute(comm:pansichar;silent:GDBBoolean): GDBInteger;virtual;
                          function executecommand(comm:pansichar): GDBInteger;virtual;
                          function executecommandsilent(comm:pansichar): GDBInteger;virtual;
                          procedure executecommandend;virtual;
                          procedure executecommandtotalend;virtual;
                          procedure executefile(fn:GDBString);virtual;
                          function executelastcommad: GDBInteger;virtual;
                          procedure sendpoint2command(p3d:gdbvertex; p2d:gdbvertex2di; mode:GDBByte;osp:pos_record);virtual;
                          procedure CommandRegister(pc:PCommandObjectDef);virtual;
                          procedure run(pc:PCommandObjectDef;operands:GDBString);virtual;
                          destructor done;virtual;
                          procedure cleareraseobj;virtual;
                          procedure DMShow;
                          procedure DMHide;
                          procedure DMClear;
                          //-----------------------------------------------------------------procedure DMAddProcedure(Text,HText:GDBString;proc:TonClickProc);
                          procedure DMAddMethod(Text,HText:GDBString;proc:DMMethod);
                          function FindCommand(command:GDBString):PCommandObjectDef;
                    end;
var commandmanager:GDBcommandmanager;
function getcommandmanager:GDBPointer;export;
{procedure startup;
procedure finalize;}
implementation
uses Objinsp,UGDBStringArray,cmdline,UGDBDescriptor;
function getcommandmanager:GDBPointer;
begin
     result:=@commandmanager;
end;
procedure GDBcommandmanager.DMShow;
begin
     if assigned(cline) then
     if assigned(CLine.DMenu) then
     CLine.DMenu.Show;
end;
procedure GDBcommandmanager.DMHide;
begin
     if assigned(cline) then
     if assigned(CLine.DMenu) then
     CLine.DMenu.Hide;
end;
procedure GDBcommandmanager.DMClear;
begin
     if assigned(cline) then
     if assigned(CLine.DMenu) then
     //-----------------------------------------------------------------CLine.DMenu.kids.free;
end;
{procedure GDBcommandmanager.DMAddProcedure(Text,HText:GDBString;proc:TonClickProc);
begin
     if assigned(cline) then
     if assigned(CLine.DMenu) then
     CLine.DMenu.AddProcedure(Text,HText,Proc);
end;}
procedure GDBcommandmanager.DMAddMethod;
begin
     if assigned(cline) then
     if assigned(CLine.DMenu) then
     CLine.DMenu.AddMethod(Text,HText,Proc);
end;


procedure GDBcommandmanager.executefile;
var
   sa:GDBGDBStringArray;
   p:pstring;
   ir:itrec;
   oldlastcomm:GDBString;
   s:gdbstring;
begin
     s:=(ExpandPath(fn));
     historyoutstr('Запущен скрипт "'+s+'";');
     busy:=true;
     shared.DisableCmdLine;

     oldlastcomm:=lastcommand;
     sa.init(200);
     sa.loadfromfile(s);
     //sa.getGDBString(1);
  p:=sa.beginiterate(ir);
  if p<>nil then
  repeat
        if (uppercase(pGDBString(p)^)<>'ABOUT')then
                                                    execute(pointer(pGDBString(p)^),false)
                                                else
                                                    begin
                                                         if not sysparam.nosplash then
                                                                                      execute(pointer(pGDBString(p)^),false)
                                                    end;
        p:=sa.iterate(ir);
  until p=nil;
  sa.FreeAndDone;
  lastcommand:=oldlastcomm;

     shared.EnableCmdLine;
     busy:=false;
end;
procedure GDBcommandmanager.sendpoint2command;
begin
     if pcommandrunning <> nil then
     begin
          pcommandrunning^.MouseMoveCallback(p3d,p2d,mode,osp);
     end;
     //clearotrack;
end;
procedure GDBcommandmanager.cleareraseobj;
var p:PCommandObjectDef;
    ir:itrec;
begin
  p:=beginiterate(ir);
  if p<>nil then
  repeat
       p^.done;
       if p^.dyn then GDBFreeMem(GDBPointer(p));
       p:=iterate(ir);
  until p=nil;
  count:=0;
end;
function GetCommandContext:TCStartAttr;
begin
     result:=0;
     if gdb.GetCurrentDWG<>nil then
                                   result:=result or CADWG;

end;
procedure ParseCommand(comm:pansichar; out command,operands:GDBString);
var
   i,p1,p2: GDBInteger;
begin
  p1:=pos('(',comm);
  p2:=pos(')',comm);
  if  p1<1 then
               begin
                    p1:=length(comm)+1;
                    p2:=p1;
               end;
  command:=copy(comm,1,p1-1);
  operands:=copy(comm,p1+1,p2-p1-1);
  command:=uppercase(Command);
end;
function GDBcommandmanager.FindCommand(command:GDBString):PCommandObjectDef;
var
   p:PCommandObjectDef;
   ir:itrec;
begin
   p:=beginiterate(ir);
   if p<>nil then
   repeat
         if uppercase(p^.CommandName)=command then
                                                  begin
                                                       result:=p;
                                                       exit;
                                                  end;

         p:=iterate(ir);
   until p=nil;
   result:=nil;
end;
procedure GDBcommandmanager.run(pc:PCommandObjectDef;operands:GDBString);
begin
          if pcommandrunning<>nil then
                                      begin
                                           if pc^.overlay then
                                                              begin
                                                                   if CommandsStack.IsObjExist(pc)
                                                                   then
                                                                       self.executecommandtotalend
                                                                   else
                                                                       begin
                                                                            CommandsStack.AddRef(pcommandrunning^)
                                                                       end;
                                                              end
                                                          else
                                                              self.executecommandtotalend;
                                      end;
          pcommandrunning := pointer(pc);
          pcommandrunning^.CommandStart(pansichar(operands));
end;
function GDBcommandmanager.execute(comm:pansichar;silent:GDBBoolean): GDBInteger;
var i,p1,p2: GDBInteger;
    command,operands:GDBString;
    cc:TCStartAttr;
    pfoundcommand:PCommandObjectDef;
begin
  if length(comm)>0 then
  if comm[0]<>';' then
  begin
  ParseCommand(comm,command,operands);
  pfoundcommand:=FindCommand(command);
  if pfoundcommand<>nil then
  begin
    begin
      cc:=GetCommandContext;
      if ((cc xor pfoundcommand^.CStartAttrEnableAttr)and pfoundcommand^.CStartAttrEnableAttr)=0
      then
          begin

          lastcommand := command;
          if silent then
                        programlog.logoutstr('GDBCommandManager.ExecuteCommandSilent('+pfoundcommand^.CommandName+');',0)
                    else
                        historyoutstr('Запущена команда('+pfoundcommand^.CommandName+');');

          run(pfoundcommand,operands);
          if pcommandrunning<>nil then
                                      if assigned(CLine) then
                                      CLine.SetMode(CLCOMMANDRUN);
          end
     else
         begin
              historyout('Команда не может быть запущена в данном контексте');
         end;
    end;
  end
  else historyout(GDBPointer('Неизвестная команда: "'+command+'"'));
  end;
end;
function GDBcommandmanager.executecommand(comm:pansichar): GDBInteger;
begin
     if not busy then
                     result:=execute(comm,false)
                 else
                     shared.ShowError('Клманда не может быть выполнена. Идет выполнение сценария');
end;
function GDBcommandmanager.executecommandsilent(comm:pansichar): GDBInteger;
begin
     if not busy then
     result:=execute(comm,true);
end;
procedure GDBcommandmanager.executecommandend;
var
   temp:PCommandRTEdObjectDef;
begin
  //ReturnToDefault;
  temp:=pcommandrunning;
  pcommandrunning := nil;
  if temp<>nil then
                   temp^.CommandEnd;
  if pcommandrunning=nil then
  if assigned(cline) then
                   CLine.SetMode(CLCOMMANDREDY);
  if self.CommandsStack.Count>0 then
                                    begin
                                         pcommandrunning:=ppointer(CommandsStack.getelement(CommandsStack.Count-1))^;
                                         dec(CommandsStack.Count);
                                    end
                                else
                                    begin
                                         self.DMHide;
                                         self.DMClear;
                                    end;
   ContextCommandParams:=nil;

end;
procedure GDBcommandmanager.executecommandtotalend;
var
   temp:PCommandRTEdObjectDef;
begin
  //ReturnToDefault;
  self.DMHide;
  self.DMClear;

  temp:=pcommandrunning;
  pcommandrunning := nil;
  if temp<>nil then
                   temp^.CommandEnd;
  if pcommandrunning=nil then
                             if assigned(CLine)then
                             CLine.SetMode(CLCOMMANDREDY);
  CommandsStack.Clear;
  ContextCommandParams:=nil;
end;
function GDBcommandmanager.executelastcommad: GDBInteger;
begin
  result:=executecommand(@lastcommand[1]);
end;
constructor GDBcommandmanager.init;
begin
  inherited init({$IFDEF DEBUGBUILD}'{8B10F808-46AD-4EF1-BCDD-55B74D27187B}',{$ENDIF}m);
  CommandsStack.init({$IFDEF DEBUGBUILD}'{8B10F808-46AD-4EF1-BCDD-55B74D27187B}',{$ENDIF}10);
end;
procedure GDBcommandmanager.CommandRegister(pc:PCommandObjectDef);
begin
  if count=max then exit;
  add(@pc);
end;
procedure comdeskclear(p:GDBPointer);
begin
     {pvardesk(p)^.name:='';
     pvardesk(p)^.vartype:=0;
     pvardesk(p)^.vartypecustom:=0;
     gdbfreemem(pvardesk(p)^.pvalue);}
end;
destructor GDBcommandmanager.done;
begin
     {self.freewithprocanddone(comdeskclear);}
     inherited done;
     CommandsStack.done;
end;
{procedure startup;
begin
  commandmanager.init(1000);
end;
procedure finalize;
begin
  commandmanager.FreeAndDone;
end;}
initialization
     {$IFDEF DEBUGINITSECTION}LogOut('commandline.initialization');{$ENDIF}
     commandmanager.init(1000);
finalization
     commandmanager.FreeAndDone;
end.
