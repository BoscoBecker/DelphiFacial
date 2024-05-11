program FaceDetectApp;

uses
  Vcl.Forms,
  Vcl.Themes,
  Vcl.Styles,
  unitFaces in 'View\unitFaces.pas' {formfaces},
  untMain in 'View\untMain.pas' {frmMain};

{$R *.res}

begin
  //ReportMemoryLeaksOnShutdown:= True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
