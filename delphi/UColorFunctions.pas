unit UColorFunctions;

interface
uses
  Windows, Classes,StrUtils, Controls, StdCtrls, SysUtils, xmldom, XMLIntf, msxmldom, XMLDoc, UTypedefs, contnrs, Dialogs,
  UGradientPoint, UColorPoint;

type
TTransferFunction = class
  private
    _currentWW, _currentWL:integer;
    _blendMode:integer;
    _gradEnabled:boolean;
    _isSistema:boolean;
    _isModificada:boolean;
    _flagColorType:integer;
    _shading:boolean;
    _clamping:boolean;
    _ambient:single;
    _diffuse:single;
    _specular:single;
    _name:string;
    _size:integer;
    _Points:TObjectList;
    _GradientPoints:TObjectList;
    _specPower:single;
    _scalarUnitDistance : single;
    function _GetGradientSize():integer;
    function _GetColorSize():integer;
  public
    property CurrentLevel : integer read _currentWL write _currentWL;
    property CurrentWindow : integer read _currentWW write _currentWW;
    property BlendMode:integer read _blendMode write _blendMode;
    property GradientSize : integer read _GetGradientSize;
    property GradientEnabled : boolean read _gradEnabled write _gradEnabled;
    property IsSistema : boolean read _isSistema write _isSistema;
    property IsModificada : boolean read _isModificada write _isModificada;
    property Name:string read _name write _name;
    property ColorType:integer read _flagColorType write _flagColorType;
    property Shading:boolean read _shading write _shading;
    property Clamping:boolean read _clamping write _clamping;
    property Ambient:single read _ambient write _ambient;
    property Diffuse:single read _diffuse write _diffuse;
    property Specular:single read _specular write _specular;
    property SpecularPower : single read _specPower write _specPower;
    property scalarOpacityUnitDistance : single read _scalarUnitDistance write _scalarUnitDistance;
    property Size : integer read _GetColorSize;
    //retorna a função como arrays. Assume que as arrays estão alocadas com o tamanho dado pela propriedade Size. Retorna
    //a qtd de elementos.
    function GetFunctionAsArray(x:PInt; c0:PFloat; c1:PFloat; c2:PFloat; c3:PFloat; midpoint:PFloat; sharpness:pFloat):integer;
    function GetFunctionAsArrayF(x:PSingle; c0:PSingle; c1:PSingle; c2:PSingle; c3:PSingle; midpoint:PSingle; sharpness:PSingle):integer;
    //function GetGradientAsArray(x:PSingle; a:PSingle; midpoint:PSingle; sharpness:PSingle):integer;
    function GetGradientAsArrayF(x:PSingle; a:PSingle; midpoint:PSingle; sharpness:PSingle):integer;
  	function GetGradientPoint(i:integer):TGradientPoint;
    function GetPoint(i:integer):TColorPoint;
    //Construtor a partir do xml
    constructor Create(TransferFunction:IXMLNode);overload;
    //Construtor de cópia
    constructor Create(Original:TTransferFunction);overload;
    //construtor default
    constructor Create();overload;
    //destrutor
    destructor Destroy();override;
    procedure DeleteGradientPoint(i:integer);
    procedure DeletePonto(i:integer);
    procedure ClearPoints();
    procedure PushPoint(_p:TColorPoint);
    procedure AddGradientPoint(_p:TGradientPoint; i:integer);
    procedure AddPoint(_p:TColorPoint; i:integer);
    procedure recalculateWL();
end;
implementation

procedure TTransferFunction.recalculateWL();
var
  largura:single;
  centro:single;
begin
  largura := TColorPoint(_Points.Items[_Points.Count-1]).X - TColorPoint(_Points.Items[0]).X;
  centro := ( TColorPoint(_Points.Items[0]).X + TColorPoint(_Points.Items[_Points.Count-1]).X) / 2;
  _currentWW := Round(largura);
  _currentWL := Round(centro);
end;

procedure TTransferFunction.DeleteGradientPoint(i:integer);
begin
  _GradientPoints.Delete(i);
end;

procedure TTransferFunction.DeletePonto(i:integer);
begin
  _Points.Delete(i);
  _size := _Points.Count;
end;

constructor TTransferFunction.Create();
begin
//  Assert(False);
  _GradientPoints := TObjectList.Create(true);
  _Points := TObjectList.Create(true);
//  recalculateWL();
end;

constructor TTransferFunction.Create(Original:TTransferFunction);
var
i:integer;
pt:TColorPoint;
gp:TGradientPoint;
begin
  //Construtor de cópia - deixa ele vivo
  //ShowMessage('construtor de cópia do TTransfer');
  _flagColorType := Original._flagColorType;
  _shading := Original._shading;
  _clamping := Original._clamping;
  _diffuse := Original._diffuse;
  _specular := Original._specular;
  _name := Original._name;
  _size := Original._size;
  _Points := TObjectList.Create(true);
  for i:=0 to Original._Points.Count-1 do
  begin
    pt := TColorPoint.Create( TColorPoint( Original._points.Items[i] ));
    _Points.Add(pt);
  end;
  _GradientPoints := TObjectList.Create(true);
  for i:=0 to Original._GradientPoints.Count-1 do
  begin
    gp := TGradientPoint.Create(TGradientPoint(Original._GradientPoints.Items[i]));
    _GradientPoints.Add(gp);
  end;
  self.recalculateWL();
end;

constructor TTransferFunction.Create(TransferFunction:IXMLNode);
var
  nRgbTransferFunction:IXMLNode;
  nColorTransferFunction:IXMLNode;
  nPiecewiseFunction:IXMLNode;
  nGradientFunction:IXMLNode;
  i,qtd:integer;
  nComponent : IXMLNode;
  _nColor : IXMLNode;
  _nOpacity : IXMLNode;

begin
 // ShowMessage('construtor do TTransfer');
  _GradientPoints := TObjectList.Create(true);
  _Points := TObjectList.Create(true);
  //pega o nome
  _name := TransferFunction.Attributes['Comment'];
  //pega o blend mode
  _blendMode := TransferFunction.Attributes['BlendMode'];
  //vai pro componente
  nComponent := TransferFunction.ChildNodes.FindNode('VolumeProperty').ChildNodes.FindNode('Component');
  //guarda o shading
  DecimalSeparator := '.';
  Shading := nComponent.Attributes['Shade'];
  Ambient := StrToFloat(nComponent.Attributes['Ambient']);
  Diffuse := StrToFloat(nComponent.Attributes['Diffuse']);
  Specular := StrToFloat(nComponent.Attributes['Specular']);
  scalarOpacityUnitDistance := StrToFloat(nComponent.Attributes['ScalarOpacityUnitDistance']);
  SpecularPower := StrToFloat(nComponent.Attributes['SpecularPower']);
  //gaurda se é pra ter clamping ou não
  nRgbTransferFunction := nComponent.ChildNodes.FindNode('RGBTransferFunction');
  nColorTransferFunction := nRgbTransferFunction.ChildNodes.FindNode('ColorTransferFunction');
  Clamping := nColorTransferFunction.Attributes['Clamping'];
  //pega os pontos
  nPiecewiseFunction := nComponent.ChildNodes.FindNode('ScalarOpacity').ChildNodes.FindNode('PiecewiseFunction');
  qtd := nPiecewiseFunction.Attributes['Size'];
  for i:=0 to qtd-1 do
  begin
    _nColor := nRgbTransferFunction.ChildNodes.First.ChildNodes[i];
    _nOpacity := nPiecewiseFunction.ChildNodes[i];
    _Points.Add(TColorPoint.Create(_nColor, _nOpacity));
  end;
  //O color type é hard-coded pra rgb
  ColorType := 0;
  //Guarda se o gradient é pra ser usado ou não
  if nComponent.Attributes['DisableGradientOpacity']='1' then
    GradientEnabled := false
  else
    GradientEnabled := true;
  //GradientEnabled := not nComponent.Attributes['DisableGradientOpacity'];
  //pega a lista de pontos de gradiente
  nGradientFunction :=  nComponent.ChildNodes.FindNode('GradientOpacity').ChildNodes.FindNode('PiecewiseFunction');
  for i:=0 to nGradientFunction.Attributes['Size']-1 do
  begin
    _nOpacity := nGradientFunction.ChildNodes[i];
    _GradientPoints.Add(TGradientPoint.Create(_nOpacity));
  end;
  _size := _Points.Count;
  recalculateWL();
end;

function TTransferFunction._GetColorSize():integer;
begin
  result := _Points.Count;
end;

function TTransferFunction.GetGradientPoint(i:integer):TGradientPoint;
begin
  result := TGradientPoint(_GradientPoints.Items[i]);
end;

function TTransferFunction._GetGradientSize():integer;
begin
  result := _GradientPoints.Count;
end;


procedure TTransferFunction.AddGradientPoint(_p:TGradientPoint; i:integer);
begin
  if i>=GradientSize then
    _GradientPoints.Add(_p)
  else
    _GradientPoints.Insert(i, _p);
end;

procedure TTransferFunction.AddPoint(_p:TColorPoint; i:integer);
begin
  _Points.Insert(i, _p);
  _size := _Points.Count;
end;

function TTransferFunction.GetPoint(i:integer):TColorPoint;
begin
  result := TColorPoint( _Points.Items[i] ); //_Points[i];
end;

procedure TTransferFunction.ClearPoints();
begin
  _Points.Clear();
  _size := _Points.Count;
end;



destructor TTransferFunction.Destroy();
begin
//    ShowMessage('destrutor do TTransfer');
  _Points.Destroy();
  _GradientPoints.Destroy();
end;

procedure TTransferFunction.PushPoint(_p:TColorPoint);
begin

  _Points.Add(_p);
  _size := _Points.Count;
  self.recalculateWL();
end;



function TTransferFunction.GetGradientAsArrayF(x:PSingle; a:PSingle; midpoint:PSingle; sharpness:PSingle):integer;
var
i:integer;
_cx:PSingle;
_a, _cmid, _csharp:PSingle;
current:TGradientPoint;
begin
  _cx:=x; _a:=a;   _cmid:=midpoint;  _csharp:=sharpness;
  for i:=0 to GradientSize-1 do
  begin
    current := TGradientPoint( _GradientPoints.Items[i] );
    _cx^ := current.X;
    _a^ := current.A;
    _cmid^ := current.Midpoint;
    _csharp^ := current.Sharpness;
    inc(_cx); inc(_a); inc(_cmid); inc(_csharp);
  end;
  result := Size;
end;





function TTransferFunction.GetFunctionAsArrayF(x:PSingle; c0:PSingle; c1:PSingle; c2:PSingle; c3:PSingle; midpoint:PSingle; sharpness:PSingle):integer;
var
i:integer;
_cx,_c0, _c1, _c2, _c3, _cmid, _csharp:PSingle;
current:TColorPoint;
begin
  _cx:=x; _c0:=c0;  _c1:=c1;  _c2:=c2;  _c3:=c3;  _cmid:=midpoint;  _csharp:=sharpness;
  for i:=0 to Size-1 do
  begin
    current := TColorPoint( _Points.Items[i] );
    _cx^ := current.X;
    _c0^ := current.C0;
    _c1^ := current.C1;
    _c2^ := current.C2;
    _c3^ := current.C3;
    _cmid^ := current.Midpoint;
    _csharp^ := current.Sharpness;

    inc(_cx); inc(_c0); inc(_c1); inc(_c2); inc(_c3); inc(_cmid); inc(_csharp);
  end;
  result := Size;
end;

function TTransferFunction.GetFunctionAsArray(x:PInt; c0:PFloat; c1:PFloat; c2:PFloat; c3:PFloat; midpoint:PFloat; sharpness:pFloat):integer;
var
i:integer;
_cx:PInt;
_c0, _c1, _c2, _c3, _cmid, _csharp:PFloat;
current:TColorPoint;
begin
  _cx:=x; _c0:=c0;  _c1:=c1;  _c2:=c2;  _c3:=c3;  _cmid:=midpoint;  _csharp:=sharpness;
  for i:=0 to Size-1 do
  begin
    current := TColorPoint( _Points.Items[i] );
    with current do
    begin
      _cx^:=trunc(X);
      _c0^:=C0;
      _c1^:=C1;
      _c2^:=C2;
      _c3^:=C3;
      _cmid^:=Midpoint;
      _csharp^:=Sharpness;
    end;
    inc(_cx); inc(_c0); inc(_c1); inc(_c2); inc(_c3); inc(_cmid); inc(_csharp);
  end;
  result := Size;
end;

end.
