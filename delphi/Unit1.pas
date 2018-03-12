unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, MyOpenGLPanel;

type
  TForm1 = class(TForm)
    btnInicio: TButton;
    tmr1: TTimer;
    procedure btnInicioClick(Sender: TObject);
    procedure tmr1Timer(Sender: TObject);
  private
    handleDaDll:cardinal;
    OutputPanel : TCustomPanel;
    CreateScreenFromContext : procedure();stdcall;
    Render: procedure();stdcall;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnInicioClick(Sender: TObject);
var
  glPanel:TMyOpenGlPanel;
begin
  //Carrega dll
  handleDaDll := LoadLibrary('C:\teste_volume_render\build\Debug\teste_vr.dll');
  //Carrega as fn
  CreateScreenFromContext := GetProcAddress(handleDaDll, '_CreateScreenFromContext@0');
  Render := GetProcAddress(handleDaDll, '_Render@0');
  //Cria��o do panel
  glPanel := TMyOpenGlPanel.create(self);
  glPanel.Parent := self;
  glPanel.Width := 300;
  glPanel.Height := 300;
  glPanel.Top := 100;
  glPanel.Left:= 1;
  glPanel.Visible := true;
  self.Refresh();
  self.Paint();
  //Testa
  glPanel.MakeCurrent();
  CreateScreenFromContext();

  tmr1.enabled := true;
end;

procedure TForm1.tmr1Timer(Sender: TObject);
begin
  Render();
end;

end.
