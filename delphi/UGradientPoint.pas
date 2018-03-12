unit UGradientPoint;
interface
uses
  Windows, Classes,StrUtils, Controls, StdCtrls, SysUtils, xmldom, XMLIntf, msxmldom, XMLDoc, UTypedefs, contnrs, Dialogs;
type
TGradientPoint = class
  private
    _x, _a, _midpoint, _sharpness :single;
  public
    property X : single read _x write _x;
    property A : single read _a write _a;
    property Midpoint : single read _midpoint write _midpoint;
    property Sharpness : single read _sharpness write _sharpness;

    constructor Create(nData:IXMLNode);overload;
    constructor Create(o:TGradientPoint);overload;
end;
implementation

constructor TGradientPoint.Create(o:TGradientPoint);
begin
  self._x := o._x;
  self._a := o._a;
  self._midpoint := o._midpoint;
  self._sharpness := o._sharpness;
end;

constructor TGradientPoint.Create(nData:IXMLNode);
begin
  X := strToFloat (nData.Attributes['X']);
  A := strToFloat (nData.Attributes['Value']);
  Midpoint := strToFloat (nData.Attributes['MidPoint']);
  Sharpness :=strToFloat (nData.Attributes['Sharpness']);
end;
end.
 