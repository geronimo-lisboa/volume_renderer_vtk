unit UColorPoint;

interface
uses
  Windows, Classes,StrUtils, Controls, StdCtrls, SysUtils, xmldom, XMLIntf, msxmldom, XMLDoc, UTypedefs, contnrs, Dialogs;

type
TColorPoint = class
  private
    _x,_v0, _v1, _v2, _v3, _midpoint, _sharpness:single;
  public
    property X : single read _x write _x;
    property C0 : single read _v0 write _v0;
    property C1 : single read _v1 write _v1;
    property C2 : single read _v2 write _v2;
    property C3 : single read _v3 write _v3;
    property Midpoint : single read _midpoint write _midpoint;
    property Sharpness : single read _sharpness write _sharpness;
    constructor Create(nColorChannel:IXMLNode; nOpacityChannel:IXMLNode);overload;
    constructor Create();overload;
    constructor Create(o:TColorPoint);overload;
end;
TColorPointArray = array of TColorPoint;

implementation

constructor TColorPoint.create(o:TColorPoint );
begin
  self._x := o._x;
  self._v0 := o._v0;
  self._v1 := o._v1;
  self._v2 := o._v2;
  self._v3 := o._v3;
  self._midpoint := o._midpoint;
  self._sharpness := o._sharpness;
end;

constructor TColorPoint.Create();
begin
  X := 0;
  C0 := 0;
  C1 := 0;
  C2 := 0;
  C3 := 0;
  Midpoint := 0;
  Sharpness :=0;
end;

constructor TColorPoint.Create(nColorChannel:IXMLNode; nOpacityChannel:IXMLNode);
var
  valueStrList : TStringList;
begin
  //Writeln( nColorChannel.NodeName);
  X := strToFloat (nColorChannel.Attributes['X']);
  //pega os valores dos canais de cor
  valueStrList := TStringList.Create;
  valueStrList.Delimiter := ' ';
  valueStrList.DelimitedText := nColorChannel.Attributes['Value'];
  DecimalSeparator := '.';
  C0 := StrToFloat(valueStrList[0]);
  C1 := StrToFloat(valueStrList[1]);
  C2 := StrToFloat(valueStrList[2]);
  //pega o midpoint e a sharpness
  Midpoint := StrToFloat(nColorChannel.Attributes['MidPoint']);
  Sharpness := StrToFloat(nColorChannel.Attributes['Sharpness']);
  //pega a opacidade
  C3 := StrToFloat(nOpacityChannel.Attributes['Value']);
  valueStrList.Destroy;
end;

end.
