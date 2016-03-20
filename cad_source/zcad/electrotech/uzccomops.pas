(*----------------------------------------------------------------------------*)
(*                  Copyright (c) 2004-2010 Antrey Zubarev                    *)
(*----------------------------------------------------------------------------*)
{
@author(Andrey Zubarev <zamtmn@yandex.ru>) 
}

unit uzccomops;
{$INCLUDE def.inc}
interface
uses

  uzctranslations,zeentitiesmanager,uzeentity,uzglviewareaabstract,uzgldrawcontext,
  uzeentabstracttext,uzeenttext,UGDBStringArray,zeentityfactory,uzcsysvars,strproc,
  gdbasetypes,uzccommandsmanager,uzclog,UGDBOpenArrayOfPObjects,plugins,
  uzccommandsabstract,uzccommandsimpl,gdbase,uzcdrawings,uzcutils,sysutils,
  varmandef,UGDBOpenArrayOfByte,uzeffdxf,zcadinterface,geometry,memman,gdbobjectsconstdef,
  uzccomdraw,UGDBVisibleOpenArray,uzeentline,paths,uzcshared,uzeentblockinsert,
  varman,uzccablemanager,uzeentdevice,uzeentmtext,math;

type
  TPlaceParam=record
                    PlaceFirst:boolean;
                    PlaceFirstOffset:double;
                    PlaceLast:boolean;
                    PlaceLastOffset:double;
                    OtherStep:double;
  end;
{Export+}
  TInsertType=(
               TIT_Block(*'Block'*),
               TIT_Device(*'Device'*)
              );
  TOPSDatType=(
               TOPSDT_Termo(*'Termo'*),
               TOPSDT_Smoke(*'Smoke'*)
              );
  TOPSMinDatCount=(
                   TOPSMDC_1_4(*'1 in the quarter'*),
                   TOPSMDC_1_2(*'1 in the middle'*),
                   TOPSMDC_2(*'2'*),
                   TOPSMDC_3(*'3'*),
                   TOPSMDC_4(*'4'*)
                  );
  TODPCountType=(
                   TODPCT_by_Count(*'by number'*),
                   TODPCT_by_XY(*'by width/height'*)
                 );
  TPlaceSensorsStrategy=(
                  TPSS_Proportional(*'Proportional'*),
                  TPSS_FixDD(*'Sensor-Sensor distance fix'*),
                  TPSS_FixDW(*'Sensor-Wall distance fix'*),
                  TPSS_ByNum(*'By number'*)
                  );
  TAxisReduceDistanceMode=(TARDM_Nothing(*'Nothing'*),
                           TARDM_LongAxis(*'Long axis'*),
                           TARDM_ShortAxis(*'Short axis'*),
                           TARDM_AllAxis(*'All xxis'*));
  PTOPSPlaceSmokeDetectorOrtoParam=^TOPSPlaceSmokeDetectorOrtoParam;
  TOPSPlaceSmokeDetectorOrtoParam=packed record
                                        InsertType:TInsertType;(*'Insert'*)
                                        Scale:GDBDouble;(*'Plan scale'*)
                                        ScaleBlock:GDBDouble;(*'Blocks scale'*)
                                        StartAuto:GDBBoolean;(*'"Start" signal'*)
                                        SensorSensorDistance:TAxisReduceDistanceMode;(*'Sensor-sensor distance reduction'*)
                                        SensorWallDistance:TAxisReduceDistanceMode;(*'Sensor-wall distance reduction'*)
                                        DatType:TOPSDatType;(*'Sensor type'*)
                                        DMC:TOPSMinDatCount;(*'Min. number of sensors'*)
                                        Height:TEnumData;(*'Height of installation'*)
                                        ReductionFactor:GDBDouble;(*'Reduction factor'*)
                                        NDD:GDBDouble;(*'Sensor-Sensor(standard)'*)
                                        NDW:GDBDouble;(*'Sensor-Wall(standard)'*)
                                        PlaceStrategy:TPlaceSensorsStrategy;
                                        FDD:GDBDouble;(*'Sensor-Sensor(fact)'*)(*oi_readonly*)
                                        FDW:GDBDouble;(*'Sensor-Wall(fact)'*)(*oi_readonly*)
                                        NormalizePoint:GDBBoolean;(*'Normalize to grid (if enabled)'*)

                                        oldth:GDBInteger;(*hidden_in_objinsp*)
                                        oldsh:GDBInteger;(*hidden_in_objinsp*)
                                        olddt:TOPSDatType;(*hidden_in_objinsp*)
                                  end;
  PTOrtoDevPlaceParam=^TOrtoDevPlaceParam;
  TOrtoDevPlaceParam=packed record
                                        Name:GDBString;(*'Block'*)(*oi_readonly*)
                                        ScaleBlock:GDBDouble;(*'Blocks scale'*)
                                        CountType:TODPCountType;(*'Type of placement'*)
                                        Count:GDBInteger;(*'Total number'*)
                                        NX:GDBInteger;(*'Number of length'*)
                                        NY:GDBInteger;(*'Number of width'*)
                                        Angle:GDBDouble;(*'Rotation'*)
                                        AutoAngle:GDBBoolean;(*'Auto rotation'*)
                                        NormalizePoint:GDBBoolean;(*'Normalize to grid (if enabled)'*)

                     end;
     GDBLine=packed record
                  lBegin,lEnd:GDBvertex;
              end;
  OPS_SPBuild={$IFNDEF DELPHI}packed{$ENDIF} object(FloatInsert_com)
    procedure Command(Operands:pansichar); virtual;
  end;

{Export-}
var
   pco,pco2:pCommandRTEdObjectPlugin;
   //pwnd:POGLWndtype;
   t3dp: gdbvertex;
   //pgdbinplugin: PGDBDescriptor;
   //psysvarinplugin: pgdbsysvariable;
   pluginspath:string;
   pvarman:pvarmanagerdef;
   pdw,pdd,pdtw,pdtd:PGDBDouble;
   pdt:pinteger;
   sdname:GDBstring;

   OPSPlaceSmokeDetectorOrtoParam:TOPSPlaceSmokeDetectorOrtoParam;
   OrtoDevPlaceParam:TOrtoDevPlaceParam;

   OPS_SPBuild_com:OPS_SPBuild;

//procedure GDBGetMem({$IFDEF DEBUGBUILD}ErrGuid:pchar;{$ENDIF}var p:pointer; const size: longword); external 'cad.exe';
//procedure GDBFreeMem(var p: pointer); external 'cad.exe';

//procedure HistoryOut(s: pchar); external 'cad.exe';
//function getprogramlog:pointer; external 'cad.exe';
//function getcommandmanager:pointer;external 'cad.exe';
//function getgdb: pointer; external 'cad.exe';
//procedure addblockinsert(pva: PGDBObjEntityOpenArray; point: gdbvertex; scale, angle: gldouble; s: pchar);external 'cad.exe';
//function Vertexmorph(Vector1, Vector2: GDBVertex; a: gldouble): GDBVertex; external 'cad.exe';
//function VertexDmorph(Vector1, Vector2: GDBVertex; a: gldouble): GDBVertex; external 'cad.exe';
//function Vertexlength(Vector1, Vector2: GDBVertex): gldouble; external 'cad.exe';
//function Vertexangle(Vector1, Vector2: GDBVertex): gldouble; external 'cad.exe';
//function Vertexdmorphabs(Vector1, Vector2: GDBVertex; a: gldouble): GDBVertex; external 'cad.exe';
//function Vertexmorphabs(Vector1, Vector2: GDBVertex; a: gldouble): GDBVertex; external 'cad.exe';
//function redrawoglwnd: integer; external 'cad.exe';
//function getpsysvar: pointer; external 'cad.exe';
//function GetPZWinManager:PTZWinManager; external 'cad.exe';
//procedure GDBObjLineInit(own:PGDBObjGenericSubEntry;var pobjline: PGDBObjLine; layerindex, LW: smallint; p1, p2: GDBvertex); external 'cad.exe';

//function GetPVarMan: pointer; external 'cad.exe';


//function CreateCommandRTEdObjectPlugin(ocs,oce,occ:comproc;obc,oac:commousefunc;name:pchar):pCommandRTEdObjectPlugin; external 'cad.exe';
{
//procedure builvldtable(x,y,z:gldouble);

}
{procedure startup;
procedure finalize;}

implementation
uses uzcenitiesvariablesextender,GDBRoot,uzglviewareadata, uzcentcable,UUnitManager,uzccomelectrical,URecordDescriptor,TypeDescriptors;
function docorrecttogrid(point:GDBVertex;need:GDBBoolean):GDBVertex;
var
   gr:GDBBoolean;
begin
     gr:=false;
     if SysVar.DWG.DWG_SnapGrid<>nil then
     if SysVar.DWG.DWG_SnapGrid^ then
                                     gr:=true;
     if (need and gr) then
                          begin
                               result:=correcttogrid(point,SysVar.DWG.DWG_Snap^);
                               {result.x:=round((point.x-SysVar.DWG.DWG_Snap.Base.x)/SysVar.DWG.DWG_Snap.Spacing.x)*SysVar.DWG.DWG_Snap.Spacing.x+SysVar.DWG.DWG_Snap.Spacing.x;
                               result.y:=round((point.y-SysVar.DWG.DWG_Snap.Base.y)/SysVar.DWG.DWG_Snap.Spacing.y)*SysVar.DWG.DWG_Snap.Spacing.y+SysVar.DWG.DWG_Snap.Spacing.y;
                               result.z:=point.z;}
                          end
                      else
                          result:=point;
end;
function GetPlaceParam(count:integer;length,sd,dd:GDBDouble;DMC:TOPSMinDatCount;ps:TPlaceSensorsStrategy):TPlaceParam;
begin
     if count=2 then
     case ps of
 TPSS_FixDD:
            if length<dd then
                             ps:=TPSS_Proportional;
 TPSS_FixDW:
            if length<2*sd then
                             ps:=TPSS_Proportional;
     end;
     case count of
          1:begin
              case dmc of
               TOPSMDC_1_4:result.PlaceFirstOffset:=1/4;
               TOPSMDC_1_2:result.PlaceFirstOffset:=1/2;
              end;
              result.PlaceFirst:=true;
              result.PlaceLast:=false;
              result.otherstep:=0;
            end;
          else
            begin
              case ps of
    TPSS_Proportional:
                      result.PlaceFirstOffset:=sd/(2*sd+(count-1)*dd);
           TPSS_FixDD:
                      result.PlaceFirstOffset:=(length-((count-1)*dd))/(2*length);
           TPSS_FixDW:
                      result.PlaceFirstOffset:=sd/length;
           TPSS_ByNum:
                      result.PlaceFirstOffset:=1/(count*2);
              end;
              result.PlaceLastOffset:=1-result.PlaceFirstOffset;
              if count>2 then
                             result.otherstep:=(result.PlaceLastOffset-result.PlaceFirstOffset)/(count-1)
                         else
                             result.otherstep:=0;
              result.PlaceFirst:=true;
              result.PlaceLast:=true;
            end;
     end;
end;
procedure place2(pva:PGDBObjEntityOpenArray;basepoint, dir: gdbvertex; count: integer; length,sd,dd: GDBDouble; name: pansichar;angle:GDBDouble;norm:GDBBoolean;scaleblock:GDBDouble;ps:TPlaceSensorsStrategy);
var line2: gdbline;
    i: integer;
    d: TPlaceParam;
begin
     d:=GetPlaceParam(count,length,sd,dd,OPSPlaceSmokeDetectorOrtoParam.DMC,ps);

     if d.PlaceFirst then
     begin
          old_ENTF_CreateBlockInsert(gdb.GetCurrentROOT,pva,
                                     gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                                     docorrecttogrid(Vertexdmorph(basepoint, dir, d.PlaceFirstOffset),norm), scaleblock, angle, name)
     end;
     if d.PlaceLast then
     begin
          old_ENTF_CreateBlockInsert(gdb.GetCurrentROOT,pva,
                                     gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                                     docorrecttogrid(Vertexdmorph(basepoint, dir, d.PlaceLastOffset),norm), scaleblock, angle, name)
     end;
     if count>2 then
     begin
         count := count - 2;
         for i := 1 to count do
         begin
             d.PlaceFirstOffset:=d.PlaceFirstOffset+d.OtherStep;
             old_ENTF_CreateBlockInsert(gdb.GetCurrentROOT,pva,
                                        gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                                        docorrecttogrid(Vertexdmorph(basepoint, dir, d.PlaceFirstOffset),norm), scaleblock, angle, name)
         end;
     end;
end;
procedure placedatcic(pva:PGDBObjEntityOpenArray;p1, p2: gdbvertex; InitialSD, InitialDD: GDBDouble; name: pansichar;norm:GDBBoolean;scaleblock: GDBDouble;ps:TPlaceSensorsStrategy);
var dx, dy: GDBDouble;
  FirstLine, SecondLine: gdbline;
  FirstCount, SecondCount, i: integer;
  dir: gdbvertex;
  mincount:integer;
  FirstLineLength,SecondLineLength:double;
  d: TPlaceParam;
  LongSD,LongDD: GDBDouble;
  ShortSD,ShortDD: GDBDouble;
begin
  dx := p2.x - p1.x;
  dy := p2.y - p1.y;
  dx := abs(dx);
  dy := abs(dy);
  FirstLine.lbegin := p1;
  SecondLine.lbegin := p1;
  if dx < dy then
  begin
    FirstLine.lend.x := p2.x;
    FirstLine.lend.y := p1.y;
    FirstLine.lend.z := 0;
    SecondLine.lend.x := p1.x;
    SecondLine.lend.y := p2.y;
    SecondLine.lend.z := 0;
  end
  else
  begin
    FirstLine.lend.x := p1.x;
    FirstLine.lend.y := p2.y;
    FirstLine.lend.z := 0;
    SecondLine.lend.x := p2.x;
    SecondLine.lend.y := p1.y;
    SecondLine.lend.z := 0;
  end;
  dir.x := SecondLine.lend.x - SecondLine.lbegin.x;
  dir.y := SecondLine.lend.y - SecondLine.lbegin.y;
  dir.z := SecondLine.lend.z - SecondLine.lbegin.z;

  LongSD:=InitialSD;
  LongDD:=InitialDD;
  ShortSD:=InitialSD;
  ShortDD:=InitialDD;
  if OPSPlaceSmokeDetectorOrtoParam.StartAuto then
  begin
  case OPSPlaceSmokeDetectorOrtoParam.SensorSensorDistance of
                                            TARDM_LongAxis:LongDD:=LongDD/2;
                                           TARDM_ShortAxis:ShortDD:=ShortDD/2;
                                             TARDM_AllAxis:begin
                                                            LongDD:=LongDD/2;
                                                            ShortDD:=ShortDD/2;
                                                           end;
  end;
  case OPSPlaceSmokeDetectorOrtoParam.SensorWallDistance of
                                            TARDM_LongAxis:LongSD:=LongSD/2;
                                           TARDM_ShortAxis:ShortSD:=ShortSD/2;
                                             TARDM_AllAxis:begin
                                                            LongSD:=LongSD/2;
                                                            ShortSD:=ShortSD/2;
                                                           end;
  end;
  end;
  if (Vertexlength(FirstLine.lbegin, FirstLine.lend) - 2 * ShortSD)>0 then FirstCount := round(abs(Vertexlength(FirstLine.lbegin, FirstLine.lend) - 2 * ShortSD) / ShortDD- eps + 1.5)
                                                         else FirstCount := 1;
  if (Vertexlength(SecondLine.lbegin, SecondLine.lend) - 2 * LongSD)>0 then SecondCount := round(abs(Vertexlength(SecondLine.lbegin, SecondLine.lend) - 2 * LongSD) / LongDD-eps + 1.5)
                                                         else SecondCount := 1;
  mincount:=2;
  case OPSPlaceSmokeDetectorOrtoParam.DMC of
                                            TOPSMDC_1_4:mincount:=1;
                                            TOPSMDC_1_2:mincount:=1;
                                            TOPSMDC_3:mincount:=3;
                                            TOPSMDC_4:mincount:=4;
                                          end;
  if FirstCount <= 0 then FirstCount := 1;
  if SecondCount <= 0 then SecondCount := 1;
  if (FirstCount*SecondCount)<mincount then
                          begin
                             case OPSPlaceSmokeDetectorOrtoParam.DMC of
                               TOPSMDC_2:SecondCount:=2;
                               TOPSMDC_3:SecondCount:=3;
                               TOPSMDC_4:
                                         begin
                                              SecondCount:=2;
                                              FirstCount:=2;
                                         end;
                             end;
                         end;
  SecondLineLength:=oneVertexlength(dir);
  FirstLineLength:=Vertexlength(FirstLine.lbegin, FirstLine.lend);

  d:=GetPlaceParam(FirstCount,FirstLineLength,ShortSD,ShortDD,TOPSMDC_1_2,ps);

  if d.PlaceFirst then
  begin
       place2(pva,Vertexmorph(FirstLine.lbegin, FirstLine.lend,d.PlaceFirstOffset), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
  end;
  if d.PlaceLast then
  begin
       place2(pva,Vertexmorph(FirstLine.lbegin, FirstLine.lend,d.PlaceLastOffset), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
  end;
  if FirstCount>2 then
  begin
       FirstCount := FirstCount - 2;
       for i := 1 to FirstCount do
       begin
           d.PlaceFirstOffset:=d.PlaceFirstOffset+d.OtherStep;
           place2(pva,Vertexmorph(FirstLine.lbegin, FirstLine.lend,d.PlaceFirstOffset), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
       end;
  end;

  {case FirstCount of
    1: begin
          place2(pva,Vertexmorph(FirstLine.lbegin, FirstLine.lend, 0.5), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
       end;
    2: begin
        if ((Vertexlength(FirstLine.lbegin, FirstLine.lend) - 2 * LongSD)<LongDD) then
        begin
          place2(pva,Vertexmorph(FirstLine.lbegin, FirstLine.lend, 1 / 4), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
          place2(pva,Vertexmorph(FirstLine.lbegin, FirstLine.lend, 3 / 4), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
        end
        else
          begin
          place2(pva,Vertexmorphabs2(FirstLine.lbegin, FirstLine.lend, LongSD), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
          place2(pva,Vertexmorphabs2(FirstLine.lbegin, FirstLine.lend, -LongSD), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,ps);
        end
       end
  else begin
          place2(pva,Vertexmorphabs2(FirstLine.lbegin, FirstLine.lend, LongSD), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,OPSPlaceSmokeDetectorOrtoParam.PlaceStrategy);
          place2(pva,Vertexmorphabs2(FirstLine.lbegin, FirstLine.lend, -LongSD), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,OPSPlaceSmokeDetectorOrtoParam.PlaceStrategy);
          SecondLine.lbegin := Vertexmorphabs2(FirstLine.lbegin, FirstLine.lend, LongSD);
          SecondLine.lend := Vertexmorphabs2(FirstLine.lbegin, FirstLine.lend, -LongSD);
          FirstCount:=FirstCount-2;
          for i := 1 to FirstCount do place2(pva,Vertexmorph(SecondLine.lbegin, SecondLine.lend, i / (FirstCount + 1)), dir, SecondCount, SecondLineLength,LongSD,LongDD, name,0,norm,scaleblock,OPSPlaceSmokeDetectorOrtoParam.PlaceStrategy);
       end
  end;}
end;
function CommandStart(operands:pansichar):GDBInteger;
begin
  GDB.AddBlockFromDBIfNeed(gdb.GetCurrentDWG,'DEVICE_PS_DAT_SMOKE');
  GDB.AddBlockFromDBIfNeed(gdb.GetCurrentDWG,'DEVICE_PS_DAT_TERMO');
  GDB.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera));
  historyout('Первый угол:');
  If assigned(SetGDBObjInspProc)then
  SetGDBObjInspProc(nil,gdb.GetUnitsFormat,SysUnit.TypeName2PTD('CommandRTEdObject'),pco,gdb.GetCurrentDWG);
  result:=cmd_ok;
end;
function BeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): integer;
begin
  result:=mclick;
  if (button and MZW_LBUTTON)<>0 then
    //if pco^.mouseclic = 1 then
    begin
      historyout('Второй угол');
      t3dp:=wc;
    end;
end;
function AfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger):GDBInteger;
var
pl:pgdbobjline;
//debug:string;
dw,dd:gdbdouble;
DC:TDrawContext;
begin


  dw:=OPSPlaceSmokeDetectorOrtoParam.NDW/OPSPlaceSmokeDetectorOrtoParam.Scale;
  dd:=OPSPlaceSmokeDetectorOrtoParam.NDD/OPSPlaceSmokeDetectorOrtoParam.Scale;
  if OPSPlaceSmokeDetectorOrtoParam.ReductionFactor<>0 then
  begin
       dw:=dw*OPSPlaceSmokeDetectorOrtoParam.ReductionFactor;
       dd:=dd*OPSPlaceSmokeDetectorOrtoParam.ReductionFactor;
  end;
  {if gdb.GetCurrentDWG.BlockDefArray.getindex(@sdname[1])<0 then
                                                         begin
                                                              sdname:=sdname;
                                                              //gdb.GetCurrentDWG.BlockDefArray.loadblock(pansichar(sysinfo.sysparam.programpath+'blocks\ops\'+sdname+'.dxf'),@sdname[1],gdb.GetCurrentDWG)
                                                         end;}
  result:=mclick;
  gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;

  pl := PGDBObjLine(ENTF_CreateLine(@gdb.GetCurrentDWG.ConstructObjRoot,@gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray,[t3dp.x,t3dp.y,t3dp.z,wc.x,wc.y,wc.z]));
  GDBObjSetEntityProp(pl,gdb.GetCurrentDWG^.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^,sysvar.dwg.DWG_CLinew^);

  //pl := pointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID{,gdb.GetCurrentROOT}));
  //GDBObjLineInit(gdb.GetCurrentROOT,pl, gdb.GetCurrentDWG.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLinew^, t3dp, wc);
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  pl^.Formatentity(gdb.GetCurrentDWG^,dc);
  if (button and MZW_LBUTTON)=0 then
  begin
       placedatcic(@gdb.GetCurrentDWG.ConstructObjRoot.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin, gdbobjline(pl^).CoordInWCS.lend, dw, dd,@sdname[1],OPSPlaceSmokeDetectorOrtoParam.NormalizePoint,OPSPlaceSmokeDetectorOrtoParam.ScaleBlock,OPSPlaceSmokeDetectorOrtoParam.PlaceStrategy);
  end
  else
  begin
       result:=-1;
       //pco^.mouseclic:=-1;
       //gdb.GetCurrentDWG.ConstructObjRoot.cleareraseobj;
       placedatcic(@gdb.GetCurrentROOT.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin, gdbobjline(pl^).CoordInWCS.lend, dw, dd,@sdname[1],OPSPlaceSmokeDetectorOrtoParam.NormalizePoint,OPSPlaceSmokeDetectorOrtoParam.ScaleBlock,OPSPlaceSmokeDetectorOrtoParam.PlaceStrategy);
       gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;

       gdb.GetCurrentROOT.calcbb(dc);
       if assigned(redrawoglwndproc) then redrawoglwndproc;
       historyout('Первый угол:');
       //commandend;
       //pcommandmanager^.executecommandend;
  end;
//  if button = 1 then
//  begin
//    pgdbinplugin^.ObjArray.add(addr(pc));
//    pgdbinplugin^.ConstructObjRoot.Count := 0;
//    commandend;
//    executecommandend;
//  end;
end;
procedure commformat;
var s:GDBString;
    pcfd:PRecordDescriptor;
    pf:PfieldDescriptor;
begin
  pcfd:=pointer(SysUnit.TypeName2PTD('TOPSPlaceSmokeDetectorOrtoParam'));
  if pcfd<>nil then
  begin
  pf:=pcfd^.FindField('SensorSensorDistance');
  if pf<>nil then
                 begin
                    if OPSPlaceSmokeDetectorOrtoParam.StartAuto then
                                                                    pf^.base.Attributes:=pf.base.Attributes and (not FA_READONLY)
                                                                else
                                                                    pf^.base.Attributes:=pf.base.Attributes or FA_READONLY;
                 end;
  pf:=pcfd^.FindField('SensorWallDistance');
  if pf<>nil then
                 begin
                    if OPSPlaceSmokeDetectorOrtoParam.StartAuto then
                                                                    pf^.base.Attributes:=pf.base.Attributes and (not FA_READONLY)
                                                                else
                                                                    pf^.base.Attributes:=pf.base.Attributes or FA_READONLY;
                 end;
  end;
     sdname:=sdname;
     if OPSPlaceSmokeDetectorOrtoParam.DatType<>OPSPlaceSmokeDetectorOrtoParam.olddt then
     begin
          OPSPlaceSmokeDetectorOrtoParam.olddt:=OPSPlaceSmokeDetectorOrtoParam.DatType;
          OPSPlaceSmokeDetectorOrtoParam.Height.Enums.clear;
          case OPSPlaceSmokeDetectorOrtoParam.DatType of
               TOPSDT_Smoke:begin
                                 s:='До 3,5м';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 s:='Св. 3,5 до 6,0';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 s:='Св. 6,0 до 10,0';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 s:='Св. 10,5 до 12,0';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 s:='Не норм.';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 OPSPlaceSmokeDetectorOrtoParam.oldth:=OPSPlaceSmokeDetectorOrtoParam.Height.Selected;
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Selected:=OPSPlaceSmokeDetectorOrtoParam.oldsh;
                            end;
               TOPSDT_Termo:begin
                                 s:='До 3,5м';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 s:='Св. 3,5 до 6,0';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 s:='Св. 6,0 до 9,0';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 s:='Не норм.';
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Enums.add(@s);
                                 OPSPlaceSmokeDetectorOrtoParam.oldsh:=OPSPlaceSmokeDetectorOrtoParam.Height.Selected;
                                 OPSPlaceSmokeDetectorOrtoParam.Height.Selected:=OPSPlaceSmokeDetectorOrtoParam.oldth;
                            end;
          end;
     end;
     case OPSPlaceSmokeDetectorOrtoParam.DatType of
          TOPSDT_Smoke:begin
                            case OPSPlaceSmokeDetectorOrtoParam.Height.Selected of
                               0:begin
                                      OPSPlaceSmokeDetectorOrtoParam.NDW:=4500;
                                      OPSPlaceSmokeDetectorOrtoParam.NDD:=9000;
                                 end;
                               1:begin
                                      OPSPlaceSmokeDetectorOrtoParam.NDW:=4000;
                                      OPSPlaceSmokeDetectorOrtoParam.NDD:=8500;
                                 end;
                               2:begin
                                      OPSPlaceSmokeDetectorOrtoParam.NDW:=4000;
                                      OPSPlaceSmokeDetectorOrtoParam.NDD:=8000;
                                 end;
                               3:begin
                                      OPSPlaceSmokeDetectorOrtoParam.NDW:=3500;
                                      OPSPlaceSmokeDetectorOrtoParam.NDD:=7500;
                                 end;
                           end;
                               {if (OPSPlaceSmokeDetectorOrtoParam.Height.Selected<>4)and OPSPlaceSmokeDetectorOrtoParam.StartAuto then
                               begin
                                    OPSPlaceSmokeDetectorOrtoParam.NDW:=OPSPlaceSmokeDetectorOrtoParam.NDW/2;
                                    OPSPlaceSmokeDetectorOrtoParam.NDD:=OPSPlaceSmokeDetectorOrtoParam.NDD/2;
                               end;}
                           sdname:='PS_DAT_SMOKE';
                     end;
          TOPSDT_Termo:begin
               case OPSPlaceSmokeDetectorOrtoParam.Height.Selected of
                               0:begin
                                      OPSPlaceSmokeDetectorOrtoParam.NDW:=2500;
                                      OPSPlaceSmokeDetectorOrtoParam.NDD:=5000;
                                 end;
                               1:begin
                                      OPSPlaceSmokeDetectorOrtoParam.NDW:=2000;
                                      OPSPlaceSmokeDetectorOrtoParam.NDD:=4500;
                                 end;
                               2:begin
                                      OPSPlaceSmokeDetectorOrtoParam.NDW:=2000;
                                      OPSPlaceSmokeDetectorOrtoParam.NDD:=4000;
                                 end;
               end;
                               {if (OPSPlaceSmokeDetectorOrtoParam.Height.Selected<>3)and OPSPlaceSmokeDetectorOrtoParam.StartAuto then
                               begin
                                    OPSPlaceSmokeDetectorOrtoParam.NDW:=OPSPlaceSmokeDetectorOrtoParam.NDW/2;
                                    OPSPlaceSmokeDetectorOrtoParam.NDD:=OPSPlaceSmokeDetectorOrtoParam.NDD/2;
                               end;}
               sdname:='PS_DAT_TERMO';
                            end;
     end;
    if OPSPlaceSmokeDetectorOrtoParam.InsertType=TIT_Device then
                                                                sdname:=DevicePrefix+sdname;
end;
{function OPS_Sensor_Mark_com(Operands:pansichar):GDBInteger;
var i: GDBInteger;
    pcable:pGDBObjCable;
    ir,ir_inNodeArray:itrec;
    pvd:pvardesk;
    currentunit:TUnit;
    ucount:gdbinteger;
    ptn:PTNodeProp;
    p:pointer;
    cman:TCableManager;
begin
  if gdb.GetCurrentDWG.ObjRoot.ObjArray.Count = 0 then exit;
  cman.init;
  cman.build;
  cman.done;

  currentunit.init('calc');
  units.loadunit(expandpath('*rtl\objcalc\opsmarkdef.pas'),(@currentunit));
  pcable:=gdb.GetCurrentDWG.ObjRoot.ObjArray.beginiterate(ir);
  if pcable<>nil then
  repeat
        if pcable^.vp.ID=GDBCableID then
        begin
             pvd:=currentunit.FindVariable('CDC_temp');
             pgdbinteger(pvd.data.Instance)^:=0;
             pvd:=currentunit.FindVariable('CDSC_temp');
             pgdbinteger(pvd.data.Instance)^:=0;
             p:=@pcable.ou;
             currentunit.InterfaceUses.addnodouble(@p);
             ucount:=currentunit.InterfaceUses.Count;





             ptn:=pcable^.NodePropArray.beginiterate(ir_inNodeArray);
             if ptn<>nil then
                repeat
                    if ptn^.DevLink<>nil then
                    begin
                         p:=@ptn^.DevLink^.bp.Owner.ou;
                         currentunit.InterfaceUses.addnodouble(@p);

                         units.loadunit(expandpath('*rtl\objcalc\opsmark.pas'),(@currentunit));

                         dec(currentunit.InterfaceUses.Count);

                         ptn^.DevLink^.bp.Owner^.Format;
                     end;

                    ptn:=pcable^.NodePropArray.iterate(ir_inNodeArray);
                until ptn=nil;




             currentunit.InterfaceUses.Count:=ucount-1;
        end;
  pcable:=gdb.GetCurrentDWG.ObjRoot.ObjArray.iterate(ir);
  until pcable=nil;

  currentunit.done;
  redrawoglwnd;
  result:=cmd_ok;
end;}
function OPS_Sensor_Mark_com(operands:TCommandOperands):TCommandResult;
var //i: GDBInteger;
    pcabledesk:PTCableDesctiptor;
    ir,ir2,ir_inNodeArray:itrec;
    pvd:pvardesk;
    defaultunit:TUnit;
    currentunit:PTUnit;
    UManager:TUnitManager;
    ucount:gdbinteger;
    ptn:PGDBObjDevice;
    p:pointer;
    cman:TCableManager;
    SaveEntUName,SaveCabUName:gdbstring;
    cablemetric,devicemetric,numingroupmetric:GDBString;
    ProcessedDevices:GDBOpenArrayOfPObjects;
    name:gdbstring;
    DC:TDrawContext;
    pcablestartsegmentvarext,pptnownervarext:PTVariablesExtender;
const
      DefNumMetric='default_num_in_group';
function GetNumUnit(uname:gdbstring):PTUnit;
begin
     //result:=nil;
     result:=UManager.internalfindunit(uname);
     if result=nil then
     begin
          result:=pointer(UManager.CreateObject);
          result.init(uname);
          result.CopyFrom(@defaultunit);
     end;
end;

begin
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  if gdb.GetCurrentROOT.ObjArray.Count = 0 then exit;
  ProcessedDevices.init({$IFDEF DEBUGBUILD}'{518968B6-90DE-4895-A27C-B28234A6DC17}',{$ENDIF}100);
  cman.init;
  cman.build;
  UManager.init;

  defaultunit.init(DefNumMetric);
  units.loadunit(SupportPath,InterfaceTranslate,expandpath('*rtl/objcalc/opsmarkdef.pas'),(@defaultunit));
  pcabledesk:=cman.beginiterate(ir);
  if pcabledesk<>nil then
  repeat
        begin
            pcablestartsegmentvarext:=pcabledesk.StartSegment^.GetExtension(typeof(TVariablesExtender));
            //pvd:=PTObjectUnit(pcabledesk.StartSegment.ou.Instance)^.FindVariable('GC_Metric');
            pvd:=pcablestartsegmentvarext^.entityunit.FindVariable('GC_Metric');
            if pvd<>nil then
                            begin
                                 cablemetric:=pvd.data.PTD.GetValueAsString(pvd.data.Instance);
                            end
                        else
                            begin
                                 cablemetric:='';
                            end;

             currentunit:=Umanager.beginiterate(ir2);
             if currentunit<>nil then
             repeat
             pvd:=currentunit.FindVariable('CDC_temp');
             pgdbinteger(pvd.data.Instance)^:=0;
             pvd:=currentunit.FindVariable('CDSC_temp');
             pgdbinteger(pvd.data.Instance)^:=1;
             currentunit:=Umanager.iterate(ir2);
             until currentunit=nil;
             currentunit:=nil;





             ptn:=pcabledesk^.Devices.beginiterate(ir_inNodeArray);
             if ptn<>nil then
                repeat
                    begin
                        pptnownervarext:=ptn^.bp.ListPos.Owner^.GetExtension(typeof(TVariablesExtender));
                        //pvd:=PTObjectUnit(ptn^.bp.ListPos.Owner.ou.Instance)^.FindVariable('GC_Metric');
                        pvd:=pptnownervarext^.entityunit.FindVariable('GC_Metric');
                        if pvd<>nil then
                                        begin
                                             devicemetric:=pvd.data.PTD.GetValueAsString(pvd.data.Instance);
                                        end
                                    else
                                        begin
                                             devicemetric:='';
                                        end;
                        //pvd:=PTObjectUnit(ptn^.bp.ListPos.Owner.ou.Instance)^.FindVariable('GC_InGroup_Metric');
                        pvd:=pptnownervarext^.entityunit.FindVariable('GC_InGroup_Metric');
                                        if pvd<>nil then
                                                        begin
                                                             numingroupmetric:=pvd.data.PTD.GetValueAsString(pvd.data.Instance);
                                                             if numingroupmetric='' then
                                                                                        numingroupmetric:=DefNumMetric;

                                                        end
                                                    else
                                                        begin
                                                             numingroupmetric:=DefNumMetric;
                                                        end;
                        if devicemetric=cablemetric then
                        begin
                        if ProcessedDevices.IsObjExist(@ptn^.bp.ListPos.Owner^)=false then
                    begin
                         currentunit:=GetNumUnit(numingroupmetric);

                         SaveCabUName:=pcablestartsegmentvarext^.entityunit.Name;
                         pcablestartsegmentvarext^.entityunit.Name:='Cable';
                         p:=@pcablestartsegmentvarext^.entityunit;
                         currentunit.InterfaceUses.addnodouble(@p);
                         ucount:=currentunit.InterfaceUses.Count;

                         SaveEntUName:=pptnownervarext^.entityunit.Name;
                         pptnownervarext^.entityunit.Name:='Entity';
                         p:=@pptnownervarext^.entityunit;
                         currentunit.InterfaceUses.addnodouble(@p);

                         units.loadunit(SupportPath,InterfaceTranslate,expandpath('*rtl/objcalc/opsmark.pas'),(currentunit));

                         ProcessedDevices.Add(@ptn^.bp.ListPos.Owner);

                         dec(currentunit.InterfaceUses.Count,2);

                         pptnownervarext^.entityunit.Name:=SaveEntUName;
                         pcablestartsegmentvarext^.entityunit.Name:=SaveCabUName;

                         PGDBObjLine(ptn^.bp.ListPos.Owner)^.Formatentity(gdb.GetCurrentDWG^,dc);
                    end
                        else
                            begin
                            pvd:=pptnownervarext^.entityunit.FindVariable('NMO_Name');
                            if pvd<>nil then
                                        begin
                                             name:='"'+pvd.data.PTD.GetValueAsString(pvd.data.Instance)+'"';
                                        end
                                    else
                                        begin
                                             name:='"без имени"';
                                        end;
                            uzcshared.HistoryOutstr(format('Попытка повторной нумерации устройства %s кабелем (сегментом кабеля) %s',[name,'"'+pcabledesk^.Name+'"']));
                            end;
                        end;

                    end;
                    //ptn^.bp.ListPos.Owner.ou.Name:=SaveEntUName;
                    ptn:=pcabledesk^.Devices.iterate(ir_inNodeArray);
                until ptn=nil;



             if currentunit<>nil then
             currentunit.InterfaceUses.Count:=ucount-1;
        end;
  pcablestartsegmentvarext^.entityunit.Name:=SaveCabUName;
  pcabledesk:=cman.iterate(ir);
  until pcabledesk=nil;

  defaultunit.done;
  UManager.done;
  cman.done;
  ProcessedDevices.ClearAndDone;
  if assigned(redrawoglwndproc) then redrawoglwndproc;
  result:=cmd_ok;
end;
procedure InsertDat2(datname,name:GDBString;var currentcoord:GDBVertex; var root:GDBObjRoot);
var
   pv:pGDBObjDevice;
   pt:pGDBObjMText;
   lx,{rx,}uy,dy:GDBDouble;
   tv:gdbvertex;
   DC:TDrawContext;
begin
          name:=strproc.Tria_Utf8ToAnsi(name);

     gdb.AddBlockFromDBIfNeed(gdb.GetCurrentDWG,datname);
     pointer(pv):=old_ENTF_CreateBlockInsert(gdb.GetCurrentROOT,@{gdb.GetCurrentROOT}root.ObjArray,
                                         gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                                         currentcoord, 1, 0,@datname[1]);
     dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
     pv^.formatentity(gdb.GetCurrentDWG^,dc);
     pv^.getoutbound(dc);

     lx:=pv.P_insert_in_WCS.x-pv.vp.BoundingBox.LBN.x;
     //rx:=pv.vp.BoundingBox.RTF.x-pv.P_insert_in_WCS.x;
     dy:=pv.P_insert_in_WCS.y-pv.vp.BoundingBox.LBN.y;
     uy:=pv.vp.BoundingBox.RTF.y-pv.P_insert_in_WCS.y;

     pv^.Local.P_insert.y:=pv^.Local.P_insert.y+dy;
     pv^.Formatentity(gdb.GetCurrentDWG^,dc);

     tv:=currentcoord;
     tv.x:=tv.x-lx-1;
     tv.y:=tv.y+(dy+uy)/2;

     if name<>'' then
     begin
     pt:=pointer(AllocEnt(GDBMtextID));
     pt^.init({gdb.GetCurrentROOT}@root,gdb.GetCurrentDWG.LayerTable.getAddres('TEXT'),sysvar.dwg.DWG_CLinew^,name,tv,2.5,0,0.65,RightAngle,jsbc,1,1);
     pt^.TXTStyleIndex:=gdb.GetCurrentDWG.GetTextStyleTable^.getelement(0);
     {gdb.GetCurrentROOT}root.ObjArray.add(@pt);
     pt^.Formatentity(gdb.GetCurrentDWG^,dc);
     end;

     currentcoord.y:=currentcoord.y+dy+uy;
end;
function InsertDat(datname,sname,ename:GDBString;datcount:GDBInteger;var currentcoord:GDBVertex; var root:GDBObjRoot):pgdbobjline;
var
//   pv:pGDBObjDevice;
//   lx,rx,uy,dy:GDBDouble;
   pl:pgdbobjline;
   oldcoord,oldcoord2:gdbvertex;
   DC:TDrawContext;
begin
     dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
     if datcount=1 then
                    InsertDat2(datname,sname,currentcoord,root)
else if datcount>1 then
                    begin
                         InsertDat2(datname,sname,currentcoord,root);
                         oldcoord:=currentcoord;
                         currentcoord.y:=currentcoord.y+10;
                         oldcoord2:=currentcoord;
                         InsertDat2(datname,ename,currentcoord,root);
                    end;
     if datcount=2 then
                       begin
                         pl:=pointer(AllocEnt(GDBLineID));
                         pl^.init({gdb.GetCurrentROOT}@root,gdb.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord,oldcoord2);
                         {gdb.GetCurrentROOT}root.ObjArray.add(@pl);
                         pl^.Formatentity(gdb.GetCurrentDWG^,dc);
                       end
else if datcount>2 then
                       begin
                         pl:=pointer(AllocEnt(GDBLineID));
                         pl^.init({gdb.GetCurrentROOT}@root,gdb.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord, Vertexmorphabs2(oldcoord,oldcoord2,2));
                         {gdb.GetCurrentROOT}root.ObjArray.add(@pl);
                         pl^.Formatentity(gdb.GetCurrentDWG^,dc);
                         pl:=pointer(AllocEnt(GDBLineID));
                         pl^.init({gdb.GetCurrentROOT}@root,gdb.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,Vertexmorphabs2(oldcoord,oldcoord2,4), Vertexmorphabs2(oldcoord,oldcoord2,6));
                         {gdb.GetCurrentROOT}root.ObjArray.add(@pl);
                         pl^.Formatentity(gdb.GetCurrentDWG^,dc);
                         pl:=pointer(AllocEnt(GDBLineID));
                         pl^.init({gdb.GetCurrentROOT}@root,gdb.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,Vertexmorphabs2(oldcoord,oldcoord2,8), oldcoord2);
                         {gdb.GetCurrentROOT}root.ObjArray.add(@pl);
                         pl^.Formatentity(gdb.GetCurrentDWG^,dc);
                       end;

     oldcoord:=currentcoord;
     currentcoord.y:=currentcoord.y+10;
     pl:=pointer(AllocEnt(GDBLineID));
     pl^.init({gdb.GetCurrentROOT}@root,gdb.GetCurrentDWG.GetCurrentLayer,sysvar.dwg.DWG_CLinew^,oldcoord,currentcoord);
     {gdb.GetCurrentROOT}root.ObjArray.add(@pl);
     pl^.Formatentity(gdb.GetCurrentDWG^,dc);
     result:=pl;
end;
procedure OPS_SPBuild.Command(Operands:pansichar);
//function OPS_SPBuild_com(Operands:pansichar):GDBInteger;
var count: GDBInteger;
    pcabledesk:PTCableDesctiptor;
    PCableSS:PGDBObjCable;
    ir,ir_inNodeArray:itrec;
    pvd:pvardesk;
//    currentunit:TUnit;
//    ucount:gdbinteger;
//    ptn:PGDBObjDevice;
//    p:pointer;
    cman:TCableManager;
    pv:pGDBObjDevice;

    coord,currentcoord:GDBVertex;
//    pbd:PGDBObjBlockdef;
    {pvn,pvm,}pvmc{,pvl}:pvardesk;

    nodeend,nodestart:PGDBObjDevice;
    isfirst:boolean;
    startmat,endmat,startname,endname,prevname:gdbstring;

    //cmlx,cmrx,cmuy,cmdy:gdbdouble;
    {lx,rx,}uy,dy:gdbdouble;
    lsave:{integer}PGDBPointer;
    DC:TDrawContext;
    pCableSSvarext,ppvvarext,pnodeendvarext:PTVariablesExtender;
begin
  if gdb.GetCurrentROOT.ObjArray.Count = 0 then exit;
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  cman.init;
  cman.build;

         GDB.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera) or (MRotateCamera));

  coord:=geometry.NulVertex;
  coord.y:=0;
  coord.x:=0;
  prevname:='';
  pcabledesk:=cman.beginiterate(ir);
  if pcabledesk<>nil then
  repeat
        PCableSS:=pcabledesk^.StartSegment;
        pCableSSvarext:=PCableSS^.GetExtension(typeof(TVariablesExtender));
        //pvd:=PTObjectUnit(PCableSS.ou.Instance)^.FindVariable('CABLE_Type');     { TODO : Сделать поиск переменных caseнезависимым }
        pvd:=pCableSSvarext^.entityunit.FindVariable('CABLE_Type');

        if pvd<>nil then
        begin
             //if PTCableType(pvd^.data.Instance)^=TCT_ShleifOPS then
             if (pcabledesk.StartDevice<>nil){and(pcabledesk.EndDevice<>nil)} then
             begin
                  uzcshared.HistoryOutStr(pcabledesk.Name);
                  //programlog.logoutstr(pcabledesk.Name,0);
                  currentcoord:=coord;
                  PTCableType(pvd^.data.Instance)^:=TCT_ShleifOPS;
                  lsave:=SysVar.dwg.DWG_CLayer^;
                  SysVar.dwg.DWG_CLayer^:=gdb.GetCurrentDWG.LayerTable.GetSystemLayer;

                  gdb.AddBlockFromDBIfNeed(gdb.GetCurrentDWG,'DEVICE_CABLE_MARK');
                  pointer(pv):=old_ENTF_CreateBlockInsert(@GDB.GetCurrentDWG.ConstructObjRoot,@{gdb.GetCurrentROOT.ObjArray}GDB.GetCurrentDWG.ConstructObjRoot.ObjArray,
                                                      gdb.GetCurrentDWG.GetCurrentLayer,gdb.GetCurrentDWG.GetCurrentLType,sysvar.DWG.DWG_CColor^,sysvar.DWG.DWG_CLinew^,
                                                      currentcoord, 1, 0,'DEVICE_CABLE_MARK');

                  SysVar.dwg.DWG_CLayer^:=lsave;
                  ppvvarext:=pv^.GetExtension(typeof(TVariablesExtender));
                  //pvmc:=PTObjectUnit(pv^.ou.Instance)^.FindVariable('CableName');
                  pvmc:=ppvvarext^.entityunit.FindVariable('CableName');
                  if pvmc<>nil then
                  begin
                      pstring(pvmc^.data.Instance)^:=pcabledesk.Name;
                  end;
                  Cable2CableMark(pcabledesk,pv);
                  pv^.formatentity(gdb.GetCurrentDWG^,dc);
                  pv^.getoutbound(dc);

                  //lx:=pv.P_insert_in_WCS.x-pv.vp.BoundingBox.LBN.x;
                  //rx:=pv.vp.BoundingBox.RTF.x-pv.P_insert_in_WCS.x;
                  dy:=pv.P_insert_in_WCS.y-pv.vp.BoundingBox.LBN.y;
                  uy:=pv.vp.BoundingBox.RTF.y-pv.P_insert_in_WCS.y;

                  pv^.Local.P_insert.y:=pv^.Local.P_insert.y+dy;
                  pv^.Formatentity(gdb.GetCurrentDWG^,dc);
                  currentcoord.y:=currentcoord.y+dy+uy;


                  isfirst:=true;
                  {nodeend:=}pcabledesk^.Devices.beginiterate(ir_inNodeArray);
                  nodeend:=pcabledesk^.Devices.iterate(ir_inNodeArray);
                  nodestart:=nil;
                  count:=0;
                  if nodeend<>nil then
                  repeat
                        if nodeend^.bp.ListPos.Owner<>pointer(gdb.GetCurrentROOT) then
                                                                          nodeend:=pointer(nodeend^.bp.ListPos.Owner);
                        pnodeendvarext:=nodeend^.GetExtension(typeof(TVariablesExtender));
                        //pvd:=PTObjectUnit(nodeend^.ou.Instance)^.FindVariable('NMO_Name');
                        pvd:=pnodeendvarext^.entityunit.FindVariable('NMO_Name');
                        if pvd<>nil then
                        begin
                             //endname:=pstring(pvd^.data.Instance)^;
                             endname:=pvd^.data.PTD.GetValueAsString(pvd^.data.Instance);
                        end
                           else endname:='';
                        //pvd:=PTObjectUnit(nodeend^.ou.Instance)^.FindVariable('DB_link');
                        pvd:=pnodeendvarext^.entityunit.FindVariable('DB_link');
                        if pvd<>nil then
                        begin
                            //endmat:=pstring(pvd^.data.Instance)^;
                            endmat:=pvd^.data.PTD.GetValueAsString(pvd^.data.Instance);
                            if isfirst then
                                           begin
                                                isfirst:=false;
                                                nodestart:=nodeend;
                                                startmat:=endmat;
                                                startname:=endname;
                                           end;
                            if startmat<>endmat then
                            begin
                                 InsertDat(nodestart^.name,startname,prevname,count,currentcoord,GDB.GetCurrentDWG.ConstructObjRoot);
                                 count:=0;
                                 nodestart:=nodeend;
                                 startmat:=endmat;
                                 startname:=endname;
                                 //isfirst:=true;
                            end;
                            inc(count);
                        end;
                        prevname:=endname;
                        nodeend:=pcabledesk^.Devices.iterate(ir_inNodeArray);
                  until nodeend=nil;
                  if nodestart<>nil then
                                        InsertDat(nodestart^.name,startname,endname,count,currentcoord,GDB.GetCurrentDWG.ConstructObjRoot).YouDeleted(gdb.GetCurrentDWG^)
                                    else
                                        InsertDat('_error_here',startname,endname,count,currentcoord,GDB.GetCurrentDWG.ConstructObjRoot).YouDeleted(gdb.GetCurrentDWG^);

                  //pvd:=PTObjectUnit(PCableSS.ou.Instance)^.FindVariable('CABLE_WireCount');
                  pvd:=pCableSSvarext^.entityunit.FindVariable('CABLE_WireCount');
                  if pvd=nil then
                                 coord.x:=coord.x+12
                             else
                                 begin
                                      if pgdbinteger(pvd^.data.Instance)^<>0 then
                                                                                  coord.x:=coord.x+6*pgdbinteger(pvd^.data.Instance)^
                                                                              else
                                                                                  coord.x:=coord.x+12;
                                 end;
             end

        end;


  pcabledesk:=cman.iterate(ir);
  until pcabledesk=nil;

  cman.done;

  if assigned(redrawoglwndproc) then redrawoglwndproc;
end;
procedure commformat2;
var
   pcfd:PRecordDescriptor;
   pf:PfieldDescriptor;
begin
   pcfd:=pointer(SysUnit.TypeName2PTD('TOrtoDevPlaceParam'));
   if pcfd<>nil then

     case OrtoDevPlaceParam.CountType of
          TODPCT_by_Count:begin
                               pf:=pcfd^.FindField('NX');
                               if pf<>nil then
                                              pf^.base.Attributes:=pf.base.Attributes or FA_READONLY;

                               pf:=pcfd^.FindField('NY');
                               if pf<>nil then
                                              pf^.base.Attributes:=pf.base.Attributes or FA_READONLY;
                               pf:=pcfd^.FindField('Count');
                               if pf<>nil then
                                              pf^.base.Attributes:=pf.base.Attributes and (not FA_READONLY);
                          end;
          TODPCT_by_XY:begin
                               pf:=pcfd^.FindField('NX');
                               if pf<>nil then
                                              pf^.base.Attributes:=pf.base.Attributes and (not FA_READONLY);

                               pf:=pcfd^.FindField('NY');
                               if pf<>nil then
                                              pf^.base.Attributes:=pf.base.Attributes and (not FA_READONLY);
                               pf:=pcfd^.FindField('Count');
                               if pf<>nil then
                                              pf^.base.Attributes:=pf.base.Attributes or FA_READONLY;
                       end;
     end;
end;
function PlCommandStart(operands:pansichar):GDBInteger;
var //i: GDBInteger;
    sd:TSelObjDesk;
begin
  OrtoDevPlaceParam.Name:='';
  sd:=GetSelOjbj;
    if sd.PFirstObj<>nil then
    if (sd.PFirstObj^.vp.ID=GDBBlockInsertID) then
    begin
         OrtoDevPlaceParam.Name:=PGDBObjBlockInsert(sd.PFirstObj)^.name;
    end
else if (sd.PFirstObj^.vp.ID=GDBDeviceID) then
    begin
         OrtoDevPlaceParam.Name:=DevicePrefix+PGDBObjBlockInsert(sd.PFirstObj)^.name;
    end;

  if (OrtoDevPlaceParam.Name='')or(sd.Count=0)or(sd.Count>1) then
                                   begin
                                        historyout('Должен быть выбран только один блок или устройство!');
                                        commandmanager.executecommandend;
                                        exit;
                                   end;

  if assigned(redrawoglwndproc) then redrawoglwndproc;
  result:=cmd_ok;
  GDB.GetCurrentDWG.wa.SetMouseMode((MGet3DPoint) or (MMoveCamera));
  historyout('Первый угол:');
  If assigned(SetGDBObjInspProc)then
  SetGDBObjInspProc(nil,gdb.GetUnitsFormat,SysUnit.TypeName2PTD('CommandRTEdObject'),pco2,gdb.GetCurrentDWG);
  OPSPlaceSmokeDetectorOrtoParam.DMC:=TOPSMDC_1_2;
end;
function PlBeforeClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): integer;
begin
  result:=mclick;
  if (button and MZW_LBUTTON)<>0 then
    begin
      historyout('Второй угол');
      t3dp:=wc;
    end
end;
procedure placedev(pva:PGDBObjEntityOpenArray;p1, p2: gdbvertex; nmax, nmin: GDBInteger; name: pansichar;a:gdbdouble;aa:gdbboolean;Norm:GDBBoolean);
var dx, dy: GDBDouble;
  line1, line2: gdbline;
  l1, l2, i: integer;
  dir: gdbvertex;
//  mincount:integer;
  sd,{dd,}sdd,{ddd,}angle:double;
  linelength:double;
begin
  angle:=a;
  dx := p2.x - p1.x;
  dy := p2.y - p1.y;
  dx := abs(dx);
  dy := abs(dy);
  line1.lbegin := p1;
  line2.lbegin := p1;
  if dx < dy then
  begin
    line1.lend.x := p2.x;
    line1.lend.y := p1.y;
    line1.lend.z := 0;
    line2.lend.x := p1.x;
    line2.lend.y := p2.y;
    line2.lend.z := 0;
    sd:=dy/nmax/2;
    //dd:=dy/nmax;
    sdd:=dx/nmin/2;
    //ddd:=dx/nmin;
  end
  else
  begin
    line1.lend.x := p1.x;
    line1.lend.y := p2.y;
    line1.lend.z := 0;
    line2.lend.x := p2.x;
    line2.lend.y := p1.y;
    line2.lend.z := 0;
    sd:=dx/nmax/2;
    //dd:=dx/nmax;
    sdd:=dy/nmin/2;
    //ddd:=dy/nmin;
    if aa then
              angle:=angle+RightAngle;

  end;
  dir.x := line2.lend.x - line2.lbegin.x;
  dir.y := line2.lend.y - line2.lbegin.y;
  dir.z := line2.lend.z - line2.lbegin.z;

  l1:=nmin;
  l2:=nmax;
  Linelength:=Vertexlength(line1.lbegin, line1.lend);
  case l1 of
    1: begin
        place2(pva,Vertexmorph(line1.lbegin, line1.lend, 0.5), dir, l2, Linelength,sd,sd*2, name,angle,norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
       end;
    2: begin
        //if (Vertexlength(line1.lbegin, line1.lend) - 2 * sd)<dd then
        begin
        place2(pva,Vertexmorph(line1.lbegin, line1.lend, 1 / 4), dir, l2, Linelength,sd,sd*2, name,angle,norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
        place2(pva,Vertexmorph(line1.lbegin, line1.lend, 3 / 4), dir, l2, Linelength,sd,sd*2, name,angle,norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
        end
        {else
        begin
        place2(pva,Vertexmorphabs(line1.lbegin, line1.lend, sd), dir, l2, sd, name);
        place2(pva,Vertexmorphabs(line1.lbegin, line1.lend, -sd), dir, l2, sd, name);
        end}
       end
  else begin
      place2(pva,Vertexmorphabs2(line1.lbegin, line1.lend, sdd{}), dir, l2, Linelength,sd,sd*2, name,angle,norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
      place2(pva,Vertexmorphabs2(line1.lbegin, line1.lend, -sdd{}), dir, l2, Linelength,sd,sd*2, name,angle,norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
      line2.lbegin := Vertexmorphabs2(line1.lbegin, line1.lend, sdd);
      line2.lend := Vertexmorphabs2(line1.lbegin, line1.lend, -sdd);
      l1:=l1-2;
      for i := 1 to l1 do place2(pva,Vertexmorph(line2.lbegin, line2.lend, i / (l1 + 1)), dir, l2, Linelength,sd,sd*2, name,angle,norm,OrtoDevPlaceParam.ScaleBlock,TPSS_Proportional);
      //for i := 1 to l2 do place3(pva,Vertexmorph(line2.lbegin, line2.lend, i / (l2 )), dir, l1, dd, name);
       end
  end;
end;
function PlAfterClick(wc: GDBvertex; mc: GDBvertex2DI; button: GDBByte;osp:pos_record;mclick:GDBInteger): integer;
var
pl:pgdbobjline;
//debug:string;
//dw,dd:gdbdouble;
nx,ny:GDBInteger;
//t:GDBInteger;
tt,tx,ty,ttx,tty:gdbdouble;
DC:TDrawContext;
begin
  //nx:=OrtoDevPlaceParam.NX;
  //ny:=OrtoDevPlaceParam.NY;
  result:=mclick;
  gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;


  pl := PGDBObjLine(ENTF_CreateLine(@gdb.GetCurrentDWG.ConstructObjRoot,@gdb.GetCurrentDWG^.ConstructObjRoot.ObjArray,[t3dp.x,t3dp.y,t3dp.z,wc.x,wc.y,wc.z]));
  GDBObjSetEntityProp(pl,gdb.GetCurrentDWG^.GetCurrentLayer,sysvar.dwg.DWG_CLType^,sysvar.dwg.DWG_CColor^,sysvar.dwg.DWG_CLinew^);
  //pl := pointer(gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.CreateObj(GDBLineID{,gdb.GetCurrentROOT}));
  //GDBObjLineInit(gdb.GetCurrentROOT,pl, gdb.GetCurrentDWG.LayerTable.GetCurrentLayer,sysvar.dwg.DWG_CLinew^, t3dp, wc);
  dc:=gdb.GetCurrentDWG^.CreateDrawingRC;
  pl^.FormatEntity(gdb.GetCurrentDWG^,dc);

     case OrtoDevPlaceParam.CountType of
          TODPCT_by_Count:begin
                               if abs(OrtoDevPlaceParam.Count)=1 then
                                          begin
                                               nx:=1;
                                               ny:=1;
                                          end
                          else
                              begin
                                   //t:=round(sqrt(abs(OrtoDevPlaceParam.Count)){+0.5});
                                   //tt:=abs(gdbobjline(pl^).CoordInOCS.lEnd.y-gdbobjline(pl^).CoordInOCS.lBegin.y)+abs(gdbobjline(pl^).CoordInOCS.lEnd.x-gdbobjline(pl^).CoordInOCS.lBegin.x);
                                   ty:=abs(gdbobjline(pl^).CoordInOCS.lEnd.y-gdbobjline(pl^).CoordInOCS.lBegin.y);
                                   tx:=abs(gdbobjline(pl^).CoordInOCS.lEnd.x-gdbobjline(pl^).CoordInOCS.lBegin.x);

                                   tt:=sqrt(tx*ty/OrtoDevPlaceParam.Count);

                                   {if tx>ty then
                                                tx:=1/ty
                                            else
                                                ty:=1/tx;}

                                   //tt:=gdbobjline(pl^).CoordInOCS.lEnd.y-gdbobjline(pl^).CoordInOCS.lBegin.y;

                                  { if abs(tt)>eps then
                                                      tt:=abs((gdbobjline(pl^).CoordInOCS.lEnd.x-gdbobjline(pl^).CoordInOCS.lBegin.x)/tt)
                                                  else
                                                      tt:=1000000000;
                                   if tt>1 then
                                              begin
                                                   //nx:=OrtoDevPlaceParam.count;
                                                   //ny:=1;
                                                   tt:=1/tt;
                                              end;

                                               begin
                                                   nx:=round(t*tx);
                                                   ny:=round(t*ty);
                                               end;}
                                   ttx:=(tx/tt);
                                   tty:=(ty/tt);

                      {             if ttx<0.5 then
                                               begin
                                                    nx:=1;
                                                    ny:=OrtoDevPlaceParam.Count;
                                               end
                              else if tty<0.5 then
                                               begin
                                                    ny:=1;
                                                    nx:=OrtoDevPlaceParam.Count;
                                               end
                              else
                                  begin
                                   nx:=round(tx/tt);
                                   ny:=round(ty/tt);
                                  end;

                                   while nx*ny<OrtoDevPlaceParam.Count do
                                   if tx<ty then
                                                inc(ny)
                                            else
                                                inc(nx)}
                                   if ttx<tty then
                                                  begin
                                                       //tt:=tx;
                                                       //tx:=ty;
                                                       //ty:=tt;

                                                       tt:=ttx;
                                                       //ttx:=tty;
                                                       tty:=tt;

                                                  end;
                                   ny:=round(tty);
                                   if ny=0 then
                                               ny:=1;
                                   if ny>OrtoDevPlaceParam.Count then
                                               ny:=OrtoDevPlaceParam.Count;
                                   nx:=ceil(OrtoDevPlaceParam.Count/ny);
                              end;
                          end;
          TODPCT_by_XY:begin
                            nx:=OrtoDevPlaceParam.NX;
                            ny:=OrtoDevPlaceParam.NY;
                       end;
     end;
  if button=0 then
  begin
       placedev(@gdb.GetCurrentDWG.ConstructObjRoot.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin, gdbobjline(pl^).CoordInWCS.lend, NX, NY,@OrtoDevPlaceParam.Name[1],OrtoDevPlaceParam.Angle,OrtoDevPlaceParam.AutoAngle,OrtoDevPlaceParam.NormalizePoint);
  end
  else
  begin
       result:=-1;
       pco^.mouseclic:=-1;
       //gdb.GetCurrentDWG.ConstructObjRoot.cleareraseobj;
       placedev(@gdb.GetCurrentROOT.ObjArray,gdbobjline(pl^).CoordInWCS.lbegin, gdbobjline(pl^).CoordInWCS.lend, NX, NY,@OrtoDevPlaceParam.Name[1],OrtoDevPlaceParam.Angle,OrtoDevPlaceParam.AutoAngle,OrtoDevPlaceParam.NormalizePoint);
       gdb.GetCurrentDWG.ConstructObjRoot.ObjArray.cleareraseobj;

       gdb.GetCurrentROOT.calcbb(dc);
       if assigned(redrawoglwndproc) then redrawoglwndproc;
       historyout('Первый угол:');
       //commandend;
       //pcommandmanager^.executecommandend;
  end;
//  if button = 1 then
//  begin
//    pgdbinplugin^.ObjArray.add(addr(pc));
//    pgdbinplugin^.ConstructObjRoot.Count := 0;
//    commandend;
//    executecommandend;
//  end;
end;
procedure startup;
begin

  OPS_SPBuild_com.init('OPS_SPBuild',0,0);
  //CreateCommandFastObjectPlugin(@OPS_SPBuild_com,'OPS_SPBuild',CADWG,0);

  CreateCommandFastObjectPlugin(@OPS_Sensor_Mark_com,'OPS_Sensor_Mark',CADWG,0);
  pco:=CreateCommandRTEdObjectPlugin(@CommandStart,nil,nil,@commformat,@BeforeClick,@AfterClick,nil,nil,'PlaceSmokeDetectorOrto',0,0);
  pco^.SetCommandParam(@OPSPlaceSmokeDetectorOrtoParam,'PTOPSPlaceSmokeDetectorOrtoParam');
  OPSPlaceSmokeDetectorOrtoParam.InsertType:=TIT_Device;
  OPSPlaceSmokeDetectorOrtoParam.Height.Enums.init(10);
  OPSPlaceSmokeDetectorOrtoParam.DatType:=TOPSDT_Smoke;
  OPSPlaceSmokeDetectorOrtoParam.StartAuto:=false;
  OPSPlaceSmokeDetectorOrtoParam.DMC:=TOPSMDC_2;
  OPSPlaceSmokeDetectorOrtoParam.Scale:=100;
  OPSPlaceSmokeDetectorOrtoParam.ScaleBlock:=1;
  OPSPlaceSmokeDetectorOrtoParam.oldth:=0;
  OPSPlaceSmokeDetectorOrtoParam.oldsh:=0;
  OPSPlaceSmokeDetectorOrtoParam.olddt:=TOPSDT_Termo;
  OPSPlaceSmokeDetectorOrtoParam.NormalizePoint:=True;
  OPSPlaceSmokeDetectorOrtoParam.PlaceStrategy:=TPSS_Proportional;
  OPSPlaceSmokeDetectorOrtoParam.ReductionFactor:=1;
  OPSPlaceSmokeDetectorOrtoParam.SensorSensorDistance:=TARDM_LongAxis;
  OPSPlaceSmokeDetectorOrtoParam.SensorWallDistance:=TARDM_Nothing;
  commformat;

  pco2:=CreateCommandRTEdObjectPlugin(@PlCommandStart,nil,nil,@commformat2,@PlBeforeClick,@PlAfterClick,nil,nil,'OrtoDevPlace',0,0);

  pco2^.SetCommandParam(@OrtoDevPlaceParam,'PTOrtoDevPlaceParam');

  OrtoDevPlaceParam.ScaleBlock:=1;
  OrtoDevPlaceParam.NX:=2;
  OrtoDevPlaceParam.NY:=2;
  OrtoDevPlaceParam.Count:=2;
  OrtoDevPlaceParam.Angle:=0;
  OrtoDevPlaceParam.AutoAngle:=false;
  OrtoDevPlaceParam.NormalizePoint:=true;
  commformat2;
  //format;
end;
procedure finalize;
begin
  OPSPlaceSmokeDetectorOrtoParam.Height.Enums.FreeAndDone;
  //result := 0;
end;
initialization
  startup;
finalization
  finalize;
end.
