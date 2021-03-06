unit sysvar;
interface
uses System;
var
  INTF_ObjInsp_WhiteBackground:GDBBoolean;
  INTF_ObjInsp_ShowHeaders:GDBBoolean;
  INTF_ObjInsp_ShowSeparator:GDBBoolean;
  INTF_ObjInsp_OldStyleDraw:GDBBoolean;
  INTF_ObjInsp_ShowFastEditors:GDBBoolean;
  INTF_ObjInsp_ShowOnlyHotFastEditors:GDBBoolean;
  INTF_ObjInsp_RowHeight_OverriderEnable:GDBBoolean;
  INTF_ObjInsp_RowHeight_OverriderValue:GDBInteger;
  INTF_ObjInsp_SpaceHeight:GDBInteger;
  INTF_ObjInsp_ShowEmptySections:GDBBoolean;
  INTF_ObjInspButtonSizeReducing:GDBInteger;
  ShowHiddenFieldInObjInsp:GDBBoolean;
  DISP_CursorSize:GDBInteger;
  DISP_OSSize:GDBDouble;
  DISP_CrosshairSize:GDBDouble;
  DISP_BackGroundColor:TRGB;
  RD_MaxRenderTime:GDBInteger;
  DISP_ZoomFactor:GDBDouble;
  DISP_SystmGeometryDraw:GDBBoolean;
  DISP_SystmGeometryDraw:GDBBoolean;
  DISP_SystmGeometryColor:TGDBPaletteColor;
  DISP_HotGripColor:TGDBPaletteColor;
  DISP_SelectedGripColor:TGDBPaletteColor;
  DISP_UnSelectedGripColor:TGDBPaletteColor;
  DWG_OSMode:TGDBOSMode;
  DISP_GripSize:GDBInteger;
  DISP_ColorAxis:GDBBoolean;
  DISP_DrawZAxis:GDBBoolean;
  RD_DrawInsidePaintMessage:TGDB3StateBool;
  DWG_PolarMode:GDBBoolean;
  RD_LineSmooth:GDBBoolean;
  RD_UseStencil:GDBBoolean;
  RD_LastRenderTime:GDBInteger;
  RD_LastUpdateTime:GDBInteger;
  RD_ID_Enabled:GDBBoolean;
  RD_ID_PrefferedRenderTime:GDBInteger;
  RD_ID_MaxDegradationFactor:GDBDouble;
  RD_RemoveSystemCursorFromWorkArea:GDBBoolean;
  DSGN_SelNew:GDBBoolean;
  DWG_EditInSubEntry:GDBBoolean;
  RD_SpatialNodeCount:GDBInteger;
  RD_SpatialNodesDepth:GDBInteger;
  DWG_RotateTextInLT:GDBBoolean;
  RD_MaxLTPatternsInEntity:GDBInteger;
  RD_PanObjectDegradation:GDBBoolean;
  DSGN_OTrackTimerInterval:GDBInteger;
  RD_Light:GDBBoolean;
  PATH_Fonts:GDBString;
  PATH_AlternateFont:GDBString;
  PATH_Support_Path:GDBString;
  DWG_HelpGeometryDraw:GDBBoolean;
  DWG_AdditionalGrips:GDBBoolean;
  DWG_SelectedObjToInsp:GDBBoolean;
  DSGN_TraceAutoInc:GDBBoolean;
  DSGN_LeaderDefaultWidth:GDBDouble;
  DSGN_HelpScale:GDBDouble;
  DSGN_LCNet:TLayerControl;
  DSGN_LCCable:TLayerControl;
  DSGN_LCLeader:TLayerControl;
  DSGN_SelSameName:GDBBoolean;
  DSGN_NavigatorsGroupByPrefix:GDBBoolean;
  DSGN_NavigatorsGroupByBaseName:GDBBoolean;
  INTF_ShowScrollBars:GDBBoolean;
  INTF_ShowDwgTabs:GDBBoolean;
  INTF_DwgTabsPosition:TAlign;
  INTF_ShowDwgTabCloseBurron:GDBBoolean;
  INTF_DefaultControlHeight:GDBInteger;
  INTF_ObjInsp_AlwaysUseMultiSelectWrapper:GDBBoolean;
  INTF_DefaultEditorFontHeight:GDBInteger;
  INTF_ThemedUpToolbars:GDBBoolean;
  INTF_ThemedRightToolbars:GDBBoolean;
  INTF_ThemedDownToolbars:GDBBoolean;
  INTF_ThemedLeftToolbars:GDBBoolean;
  RD_Vendor:GDBString;
  RD_Renderer:GDBString;
  RD_Extensions:GDBString;
  RD_Version:GDBString;
  RD_GLUVersion:GDBString;
  RD_GLUExtensions:GDBString;
  RD_Restore_Mode:TRestoreMode;
  RD_VSync:TGDB3StateBool;
  SAVE_Auto_Interval:GDBInteger;
  SAVE_Auto_Current_Interval:GDBInteger;
  SAVE_Auto_FileName:GDBString;
  SAVE_Auto_On:GDBBoolean;
  SYS_RunTime:GDBInteger;
  SYS_Version:GDBString;
  PATH_Device_Library:GDBString;
  PATH_Template_Path:GDBString;
  PATH_Template_File:GDBString;
  PATH_Program_Run:GDBString;
  PATH_LayoutFile:GDBString;
  testGDBBoolean:GDBBoolean;
  pi:GDBDouble;
implementation
begin
  INTF_ObjInsp_WhiteBackground:=False;
  INTF_ObjInsp_ShowHeaders:=True;
  INTF_ObjInsp_ShowSeparator:=True;
  INTF_ObjInsp_OldStyleDraw:=False;
  INTF_ObjInsp_ShowFastEditors:=True;
  INTF_ObjInsp_ShowOnlyHotFastEditors:=False;
  INTF_ObjInsp_RowHeight_OverriderEnable:=False;
  INTF_ObjInsp_RowHeight_OverriderValue:=21;
  INTF_ObjInsp_SpaceHeight:=3;
  INTF_ObjInsp_ShowEmptySections:=False;
  INTF_ObjInspButtonSizeReducing:=4;
  ShowHiddenFieldInObjInsp:=False;
  DISP_CursorSize:=6;
  DISP_OSSize:=10.0;
  DISP_CrosshairSize:=0.05;
  DISP_BackGroundColor.r:=0;
  DISP_BackGroundColor.g:=0;
  DISP_BackGroundColor.b:=0;
  DISP_BackGroundColor.a:=255;
  RD_MaxRenderTime:=0;
  DISP_ZoomFactor:=1.624;
  DISP_SystmGeometryDraw:=False;
  DISP_SystmGeometryDraw:=False;
  DISP_SystmGeometryColor:=250;
  DISP_HotGripColor:=11;
  DISP_SelectedGripColor:=12;
  DISP_UnSelectedGripColor:=150;
  DWG_OSMode:=14311;
  DISP_GripSize:=10;
  DISP_ColorAxis:=False;
  DISP_DrawZAxis:=False;
  RD_DrawInsidePaintMessage:=T3SB_Default;
  DWG_PolarMode:=True;
  RD_LineSmooth:=False;
  RD_UseStencil:=True;
  RD_LastRenderTime:=1;
  RD_LastUpdateTime:=0;
  RD_ID_Enabled:=False;
  RD_ID_PrefferedRenderTime:=20;
  RD_ID_MaxDegradationFactor:=0.0;
  RD_RemoveSystemCursorFromWorkArea:=True;
  DSGN_SelNew:=False;
  DWG_EditInSubEntry:=False;
  RD_SpatialNodeCount:=-1;
  RD_SpatialNodesDepth:=16;
  DWG_RotateTextInLT:=True;
  RD_MaxLTPatternsInEntity:=10000;
  RD_PanObjectDegradation:=False;
  DSGN_OTrackTimerInterval:=500;
  RD_Light:=False;
  PATH_Fonts:='*fonts/|C:/Program Files/AutoCAD 2010/Fonts/|C:/APPS/MY/acad/support/|C:\Program Files\Autodesk\AutoCAD 2012 - Russian\Fonts\|C:\Windows\Fonts\';
  PATH_AlternateFont:='_mipGost.shx';
  PATH_Support_Path:='*rtl|*rtl/objdefunits|*rtl/objdefunits/include|*components|*blocks/el/general|*rtl/styles';
  DWG_HelpGeometryDraw:=True;
  DWG_AdditionalGrips:=False;
  DWG_SelectedObjToInsp:=True;
  DSGN_TraceAutoInc:=False;
  DSGN_LeaderDefaultWidth:=10.0;
  DSGN_HelpScale:=1.0;
  DSGN_LCNet.Enabled:=True;
  DSGN_LCNet.LayerName:='DEFPOINTS';
  DSGN_LCCable.Enabled:=True;
  DSGN_LCCable.LayerName:='EL_KABLE';
  DSGN_LCLeader.Enabled:=True;
  DSGN_LCLeader.LayerName:='TEXT';
  DSGN_SelSameName:=False;
  DSGN_NavigatorsGroupByPrefix:=True;
  DSGN_NavigatorsGroupByBaseName:=True;
  INTF_ShowScrollBars:=True;
  INTF_ShowDwgTabs:=True;
  INTF_DwgTabsPosition:=TATop;
  INTF_ShowDwgTabCloseBurron:=True;
  INTF_DefaultControlHeight:=27;
  INTF_ObjInsp_AlwaysUseMultiSelectWrapper:=True;
  INTF_DefaultEditorFontHeight:=0;
  INTF_ThemedUpToolbars:=true;
  INTF_ThemedRightToolbars:=false;
  INTF_ThemedDownToolbars:=false;
  INTF_ThemedLeftToolbars:=false;
  RD_Vendor:='NVIDIA Corporation';
  RD_Renderer:='GeForce GTX 460/PCIe/SSE2';
  RD_Extensions:='';
  RD_Version:='4.3.0';
  RD_GLUVersion:='1.3';
  RD_GLUExtensions:='GLU_EXT_nurbs_tessellator GLU_EXT_object_space_tess ';
  RD_Restore_Mode:=WND_Texture;
  RD_VSync:=T3SB_Fale;
  SAVE_Auto_Interval:=300;
  SAVE_Auto_Current_Interval:=300;
  SAVE_Auto_FileName:='*autosave/autosave.dxf';
  SAVE_Auto_On:=True;
  SYS_RunTime:=3233;
  SYS_Version:='0.9.8 Revision SVN:1609';
  PATH_Device_Library:='*programdb|c:/zcad/userdb';
  PATH_Template_Path:='*template';
  PATH_Template_File:='default.dxf';
  PATH_Program_Run:='E:\zcad\cad\';
  PATH_LayoutFile:='E:\zcad\cad\components/defaultlayout.xml';
  testGDBBoolean:=False;
  pi:=3.14159265359;
end.