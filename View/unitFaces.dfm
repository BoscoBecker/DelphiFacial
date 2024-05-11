object formfaces: Tformfaces
  Left = 0
  Top = 0
  Align = alLeft
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Saved Faces'
  ClientHeight = 612
  ClientWidth = 182
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OnShow = FormShow
  TextHeight = 13
  object Label1: TLabel
    Left = 9
    Top = 16
    Width = 163
    Height = 13
    Alignment = taCenter
    Caption = 'Imagens'
  end
  object Listface: TListView
    Left = 9
    Top = 40
    Width = 163
    Height = 532
    Columns = <>
    IconOptions.AutoArrange = True
    StyleElements = []
    TabOrder = 0
  end
  object Button1: TButton
    Left = 9
    Top = 578
    Width = 163
    Height = 25
    Caption = 'Delete'
    TabOrder = 1
    OnClick = Button1Click
  end
end
