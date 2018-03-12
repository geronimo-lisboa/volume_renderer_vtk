{$SetPEFlags $20}
program Project1;
{$R 'color_transfer_functions.res' 'color_transfer_functions.rc'}
uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  MyOpenGLContext in 'MyOpenglContext.pas',
  MyOpenGlPanel in 'MyOpenGlPanel.pas',
  UColorPoint in 'UColorPoint.pas',
  UGradientPoint in 'UGradientPoint.pas',
  UColorFunctions in 'UColorFunctions.pas',
  USendColorToDll in 'USendColorToDll.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
