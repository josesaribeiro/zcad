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

unit ugdbdrawingdef;
interface
uses gdbase,gdbasetypes,UGDBLayerArray,UUnitManager;
type
{EXPORT+}
PTDrawingDef=^TDrawingDef;
TDrawingDef=object(GDBaseobject)
                       function GetLayerTable:PGDBLayerArray;virtual;abstract;
                       function GetDWGUnits:PTUnitManager;virtual;abstract;
                       function GetCurrentRootSimple:GDBPointer;virtual;abstract;
                 end;
{EXPORT-}
implementation
end.
