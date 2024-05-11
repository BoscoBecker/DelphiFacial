unit UnitFaces;
interface
uses
  //OPENCV Uses
  ocv.imgproc_c,
  ocv.imgproc.types_c,
  ocv.core.types_c,
  ocv.core_c,
  ocv.highgui_c,
  ocv.objdetect_c,
  ocv.utils,
  ocv.cls.contrib,
  ocv.legacy,
  SqlExpr,
  Data.DbxSqlite,
  Jpeg,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.ExtDlgs, System.ImageList,
  Vcl.ImgList;
type
  Tformfaces = class(TForm)
    Listface: TListView;
    Button1: TButton;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  end;

  var formfaces: Tformfaces = nil;

implementation

uses untMain;
{$R *.dfm}
procedure Tformfaces.Button1Click(Sender: TObject);
begin
  if (listface.ItemIndex=-1) then exit;
  untMain.sqliteQuery.SQL.Text := 'DELETE FROM tfaces Where id = :xid;';
  untMain.sqliteQuery.ParamByName('xid').Value := listface.Items[listface.ItemIndex].Indent;
  untMain.sqliteQuery.ExecSQL();
  untMain.sqliteQuery.SQL.Text := 'VACUUM;';
  untMain.sqliteQuery.ExecSQL();
  untMain.sqliteQuery.Close;
  listface.Items[listface.ItemIndex].Delete;
end;
procedure Tformfaces.FormCreate(Sender: TObject);
begin
  frmMain.LoadFaces(Sender);
  frmMain.LoadDatabase;
  listface.ViewStyle := vsIcon;
  listface.LargeImages := untMain.oImagelface;
  for var I := 0 to untMain.dbNumfaces-1 do
  begin
    with listface.Items.Add do
    begin
      Caption := untMain.oNameslist[I];
      ImageIndex := I;
      Indent := untMain.vIdlist[I];
    end;
  end;
  untMain.oNameslist.Free;
end;

procedure Tformfaces.FormShow(Sender: TObject);
begin
  untMain.oNameslist.Free;
  untMain.oNameslist  := TStringList.Create;
  untMain.oImagelface.Free;
  untMain.oImagelface := TimageList.Create(self);
  untMain.oImagelface.SetSize(WORK_WIDTH-28,WORK_HEIGHT-28);
  frmMain.DoSQLiteConnect;
  frmMain.LoadDatabase;
  Listface.Clear;
  Listface.ViewStyle := vsIcon;
  Listface.LargeImages := untMain.oImagelface;
  for var iIndex := 0 to untMain.dbNumfaces-1 do
  begin
    with listface.Items.Add do
    begin
      Caption := untMain.oNameslist[iIndex];
      ImageIndex := iIndex;
      Indent := untMain.vIdlist[iIndex];
    end;
  end;
end;
end.
