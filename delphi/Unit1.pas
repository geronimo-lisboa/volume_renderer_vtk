unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, MyOpenGLPanel, xmldom, XMLIntf, msxmldom, XMLDoc, Contnrs,
  UColorFunctions;

type
  TForm1 = class(TForm)
    btnInicio: TButton;
    tmr1: TTimer;
    btnSwitchCor: TButton;
    procedure btnInicioClick(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
    procedure btnSwitchCorClick(Sender: TObject);
  private
    handleDaDll:cardinal;
    OutputPanel : TMyOpenGlPanel;

    CreateScreenFromContext : procedure();stdcall;
    Render: procedure();stdcall;
    Dll_SetFuncaoDeCor:procedure(var data:TColorTransferFunctionRecord);stdcall;

    procedure LoadDLL();
    procedure LoadColors();
    function CreatePanel():TMyOpenGlPanel;
    function LoadFunctionResource(resourceName:string):TResourceStream;
  public
    FuncoesDeCor:TObjectList;
    procedure SetFuncaoDeCor(index:integer);
  end;

var
  Form1: TForm1;
  currentCor:integer;
implementation
{$R *.dfm}
procedure TForm1.SetFuncaoDeCor(index:integer);
var
  rCor:TColorTransferFunctionRecord;
begin
  rCor:= TTransferFunction(FuncoesDeCor.Items[index]).GetAsRecord();
  Dll_SetFuncaoDeCor(rCor);
end;

//Usada nesse tutorial pra carregar os resources como streams para emular uma
//fonte de dados
function TForm1.LoadFunctionResource(resourceName:string):TResourceStream;
var
  rStream : TResourceStream;
begin
  try
    rStream := TResourceStream.Create(HInstance, resourceName, RT_RCDATA);
  except
    on e:Exception do
    begin
      result:=nil;
      exit;
    end;
  end;
  result := rStream;
  result.Position := 0;
end;

procedure TForm1.LoadColors();
var
  nomesDasCTF:array of string;
  i:integer;
  _ctfStream:TResourceStream;
  doc:IXMLDocument;
  nomedacurva:string;
  loadedColor :TTransferFunction;
begin
  //O nome das funções de transferência
  SetLength(nomesDasCTF, 5);
  nomesDasCTF[0] := 'CT_Coronary_Arteries_3';
  nomesDasCTF[1] := 'CT_BONE';
  nomesDasCTF[2] := 'OSIRIX_HI_CONTRAST';
  nomesDasCTF[3] := 'CT_Chest_Vessels';
  nomesDasCTF[4] := 'CT_AAA';
  //Carrega elas e guarda-as
  for i:=0 to length(nomesDasCTF)-1 do
  begin
    _ctfStream := LoadFunctionResource(nomesDasCTF[i]); //assume estar no mesmo dir que o exe
    //Cria o xml a partir do stream e depois deleta o stream.
    doc := TXMLDocument.Create(nil);
    doc.LoadFromStream(_ctfStream);
    _ctfStream.Destroy();
    doc.Active := true;
    nomedaCurva:=doc.DocumentElement.Attributes['Comment'];
    //Verifica se a lista já foi criada.
    if(Assigned(FuncoesDeCor)=false)
      then FuncoesDeCor:=TObjectList.Create(true);
    //Começa a percorrer o xml
    loadedColor := TTransferFunction.create(doc.DocumentElement);
    loadedColor.Name := nomeDaCurva;
    loadedColor.IsSistema := false;
    loadedColor.IsModificada := false;
    FuncoesDeCor.add(loadedColor);
  end;
end;

procedure TForm1.btnInicioClick(Sender: TObject);
begin
  //Carrega as cores pra lista de cores
  //Carrega a dll
  LoadDLL();
  //Carrega as cores
  LoadColors();
  //Criação do panel
  OutputPanel := CreatePanel();//É aqui que eu crio o panel E O VOLUME no momento.

  //Testa
  OutputPanel.MakeCurrent();
  CreateScreenFromContext();

  SetFuncaoDeCor(0);

  tmr1.enabled := true;
end;

procedure TForm1.tmr1Timer(Sender: TObject);
begin
  Render();
end;

procedure TForm1.LoadDLL();
begin
  //Carrega dll
  handleDaDll := LoadLibrary('C:\teste_volume_render\build\Debug\teste_vr.dll');
  //Carrega as fn
  CreateScreenFromContext := GetProcAddress(handleDaDll, '_CreateScreenFromContext@0');
  Render := GetProcAddress(handleDaDll, '_Render@0');
  Dll_SetFuncaoDeCor := GetProcAddress(handleDaDll, '_SetFuncaoDeCor@4');
end;

function TForm1.CreatePanel():TMyOpenGlPanel;
var
  glPanel:TMyOpenGlPanel;
begin
  //Criação do panel
  glPanel := TMyOpenGlPanel.create(self);
  glPanel.Parent := self;
  glPanel.Width := 300;
  glPanel.Height := 300;
  glPanel.Top := 100;
  glPanel.Left:= 1;
  glPanel.Visible := true;
  self.Refresh();
  self.Paint();
  result:=glPanel;
end;

procedure TForm1.btnSwitchCorClick(Sender: TObject);
begin
  SetFuncaoDeCor(currentCor);
  inc(currentCor);
end;

end.

