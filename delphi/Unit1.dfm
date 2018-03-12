object Form1: TForm1
  Left = 392
  Top = 196
  Width = 447
  Height = 526
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnInicio: TButton
    Left = 0
    Top = 0
    Width = 75
    Height = 25
    Caption = 'btnInicio'
    TabOrder = 0
    OnClick = btnInicioClick
  end
  object btnSwitchCor: TButton
    Left = 80
    Top = 0
    Width = 75
    Height = 25
    Caption = 'btnSwitchCor'
    TabOrder = 1
    OnClick = btnSwitchCorClick
  end
  object tmr1: TTimer
    Enabled = False
    Interval = 100
    OnTimer = tmr1Timer
    Left = 384
    Top = 80
  end
end
