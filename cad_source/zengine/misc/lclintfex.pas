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

unit lclintfex;
{$INCLUDE def.inc}
interface

uses
 {$IFDEF WINDOWS}windows,{$ENDIF}
 {$IFDEF LCLQT}qt4,qtobjects,{$ENDIF}
 LCLType,LCLIntf,gdbase;
const
     GM_COMPATIBLE=1;
     GM_ADVANCED=2;
 {$IFNDEF WINDOWS}type winbool=longint;{$ENDIF}

function AddFontResourceFile(FontResourceFileName:string):integer;
function SetGraphicsMode_(hdc:HDC; iMode:longint):longint;
function SetWorldTransform_(hdc:HDC; var tm:DMatrix4D):WINBOOL;
function SetTextAlignToBaseLine(hdc:HDC):UINT;
implementation
{$IFDEF WINDOWS}
  function __AddFontResourceEx(_para1:LPCSTR; flags:DWORD; reserved:Pointer) : integer; stdcall; external 'gdi32' name 'AddFontResourceExA';
  //function __SetGraphicsMode(hdc:HDC; iMode:longint):longint; external 'gdi32' name 'SetGraphicsMode';
  //function __SetWorldTransform(_para1:HDC; var _para2:XFORM):WINBOOL; external 'gdi32' name 'SetWorldTransform';
{$ENDIF}
function SetTextAlignToBaseLine(hdc:HDC):UINT;
begin
  {$IFDEF WINDOWS}
    SetTextAlign(hdc,TA_BASELINE{ or TA_LEFT});
  {$ENDIF}
  {$IFDEF LCLQT}
  TQtDeviceContext(hdc).translate(0,-TQtDeviceContext(hdc).Metrics.ascent)
  {$ENDIF}
end;
function AddFontResourceFile(FontResourceFileName:string):integer;
begin
  {$IFDEF WINDOWS}
    result:=__AddFontResourceEx(@FontResourceFileName[1],$10,0);
  {$Else}
    result:=1;
  {$ENDIF}
end;
function SetGraphicsMode_(hdc:HDC; iMode:longint):longint;
begin
  {$IFDEF WINDOWS}
    result:=windows.SetGraphicsMode(hdc,iMode);
  {$Else}
    result:=1;
  {$ENDIF}
end;
function SetWorldTransform_(hdc:HDC; var tm:DMatrix4D):WINBOOL;
{$IFDEF WINDOWS}
  var
    _m:XFORM;
{$ENDIF}
{$IFDEF LCLQT}
  var
  //QtDC: TQtDeviceContext absolute hdc;
  matr:QMatrixH;
{$ENDIF}
begin
  {$IFDEF WINDOWS}
  _m.eM11:=tm[0,0];
  _m.eM12:=tm[0,1];
  _m.eM21:=tm[1,0];
  _m.eM22:=tm[1,1];
  _m.eDx:=tm[3,0];
  _m.eDy:=tm[3,1];
  result:=SetWorldTransform(hdc,_m);
  {$ENDIF}
  {$IFDEF LCLQT}
    //QtDC.pa;
    matr:=QMatrix_create(tm[0,0],tm[0,1],tm[1,0],tm[1,1],tm[3,0],tm[3,1]);
    QPainter_setWorldMatrix(TQtDeviceContext(hdc).Widget,matr,false);
    //setWorldTransform
  {$ENDIF}
end;

initialization
finalization
end.

