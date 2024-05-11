﻿unit untMain;

interface

uses
  Windows,
  Messages,
  SysUtils,
  Variants,
  Classes,
  Graphics,
  Controls,
  VCL.Forms,
  VCL.Dialogs,
  ExtCtrls,
  StdCtrls, Vcl.ExtDlgs,
  Jpeg, System.ImageList, Vcl.ImgList,
  ocv.imgproc_c,
  ocv.imgproc.types_c,
  ocv.core.types_c,
  ocv.core_c,
  ocv.highgui_c,
  ocv.objdetect_c,
  ocv.utils,
  ocv.cls.contrib,
  ocv.legacy,
  IniFiles,
  SqlExpr,
  Vcl.WinXCtrls,
  GIFImg,ActiveX, DirectShow9, ComObj, Vcl.Imaging.pngimage;

type
    TipoImagem =  (tpGranted,tpDenied);


type
   PRGB24 = ^TRGB24;
   TRGB24 = record B, G, R: Byte; end;
   PRGBArray = ^TRGBArray;
   TRGBArray = array[0..0] of TRGB24;
   pfaceImage = ^TfaceImage;

   TfaceImage = record
     MyCapture: pCvCapture;       // Capture handle
     MyInputImage: pIplImage;     // Input image
     MyStorage: pCvMemStorage;    // Memory storage
     TotalFaceDetect: Integer;    // Total face detect
  end;

  TfrmMain = class(TForm)
    ImageListButtons: TImageList;
    Timer1: TTimer;
    SavePictureDialog1: TSavePictureDialog;
    OpenPictureDialog1: TOpenPictureDialog;
    GroupBox1: TGroupBox;
    Button3: TButton;
    btnRostos: TButton;
    Button2: TButton;
    cbExcluirImagem: TCheckBox;
    GroupBox3: TGroupBox;
    Edit1: TEdit;
    Button4: TButton;
    pnDetect: TPanel;
    Image2: TImage;
    PnlLoading: TPanel;
    Image3: TImage;
    LabelTimer: TLabel;
    Label1: TLabel;
    Button6: TButton;
    Button1: TButton;
    GroupBox2: TGroupBox;
    pnImagem: TPanel;
    Image1: TImage;
    GroupBox4: TGroupBox;
    Denied: TImage;
    Granted: TImage;
    lbName: TLabel;
    btnPausar: TButton;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure btnRostosClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button6Click(Sender: TObject);
    procedure Button1MouseEnter(Sender: TObject);
    procedure Button1MouseLeave(Sender: TObject);
    procedure btnPausarClick(Sender: TObject);
  private
    m_iCameraIndex : Integer;
    FrameBitmap: TBitmap;
    SessionEnding: Boolean;
    MyfaceImage: pfaceImage;
    font: TCvFont;
    GlobalSize: TCvSize;
    LiveFacesToTest:pIplImage;
    inComingfaces0: pIplImage;
    iplcoloredfacesave:pIplImage;
    iplgrayfacesave:pIplImage;
    ipllivefaceshow: pIplImage;
    ReSizeFrame:pIplImage;
    FFoundFace: boolean;
    FDetected: boolean;
    FLog: TStringlist;
    procedure ChangeImageExposure(src: TBitmap; k: Single);
    procedure StartCapture(camnum:integer);
    procedure StopCapture;
    procedure OnIdle(Sender: TObject; var Done: Boolean);
    procedure WMQueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION;
    function DetectAndDraw(const faceImage: pfaceImage) : Boolean;
    procedure JustDetect;
    procedure ClearWindow;
    procedure CreateDataFile(const sFile : String);
    procedure StreamToVariant (Stream : TMemoryStream; var v : OleVariant);
    function JPEGToVariant(aJPEG : TJPEGImage) : OleVariant;
    procedure InitVariables;
    procedure InitDB;
    procedure InitPaths;
    procedure VariantToStream (const v : olevariant; Stream : TMemoryStream);
    procedure VariantToJPEGToBMP(aValue:OleVariant; var aJPEG:TJPEGImage; var aBMP:TBitmap);
    procedure ReadConfig;
    procedure SetFoundFace(const Value: boolean);
    procedure SetDetected(const Value: boolean);
    procedure SetLog(const Value: TStringlist);
    procedure SetLoadingVisible(const Value: Boolean);
    procedure ValidaReconhecimentoFace(const FaceDetected: boolean);
    procedure AtualizaImagemReconhecimento(const Imagem: TipoImagem);
    procedure LimpaImageReconhecimento;
    //procedure EnumerateVideoInputDevices;

  public
    Destructor Destroy; override;
    Procedure GarbageCollector;//TrimAppMemorySize
    procedure LoadDatabase;
    procedure LoadFaces(Sender: TObject);
    function DoSQLiteConnect : Boolean;
    property FoundFace: boolean read FFoundFace write SetFoundFace;
    property Detected: boolean read FDetected write SetDetected;
    property Log : TStringlist read FLog write SetLog;
    property LoadingVisible: Boolean write  SetLoadingVisible;
  end;

var
  frmMain: TfrmMain = nil;
  FaceCascadeFile : AnsiString;
  FaceCascade     : pCvHaarClassifierCascade = nil;
  EyesCascade     : pCvHaarClassifierCascade = nil;
  StoragePath     : AnsiString;

  dbNumfaces     : Integer = 0;
  mi_countprints : Integer;

  oImagelface : TimageList;
  oNameslist  : TStringList;
  vIdlist     : array of integer;
  fimages    : TInputArrayOfIplImage;
  flabels    : TInputArrayOfInteger;
threadvar
  oBitmapDisplay      : TBitmap;
  inputPt1, inputPt2  : TCvPoint;
  sqliteConn          : TSQLConnection;
  sqliteQuery         : TSQLQuery;
  lbpface_id          : IFaceRecognizer;
  lbpgender_id        : IFaceRecognizer;
  lbpemo_id           : IFaceRecognizer;

  fxnames             : array of string;
  gfxnames            : array of string;
  efxnames            : array of string;
  MyHandle            : THandle;
  xgetfrom            : String;
const
  WORK_WIDTH  = 128;
  WORK_HEIGHT = 128;

implementation

{$R *.dfm}

uses UnitFaces;

procedure TfrmMain.AtualizaImagemReconhecimento(const Imagem: TipoImagem);
begin
  case imagem of
    tpGranted:
    begin
      granted.Visible:= True;
      denied.Visible:= False;
    end;
    tpDenied:
    begin
      granted.Visible:= False;
      denied.Visible:= True;
    end;
  end;
end;

procedure TfrmMain.Button1Click(Sender: TObject);

begin
  LimpaImageReconhecimento;
  SetLoadingVisible(True);
  ClearWindow;
  StopCapture;
  mi_countprints := 0;
  LabelTimer.Caption := '5';
  Timer1.Enabled := True;
  StartCapture(m_iCameraIndex);
  btnRostos.Enabled:= False;
  TGIFImage(image3.Picture.Graphic).Animate := True;
  btnPausar.Enabled:= True;
end;

procedure TfrmMain.Button1MouseEnter(Sender: TObject);
begin
  button1.Font.Color:= clGray;
end;

procedure TfrmMain.Button1MouseLeave(Sender: TObject);
begin
    button1.Font.Color:= clblack;
end;

procedure TfrmMain.Button2Click(Sender: TObject);
begin
  ClearWindow;
  btnRostos.Enabled:= True;
end;

procedure TfrmMain.Button3Click(Sender: TObject);
var
  iBrightCycle : Integer;
  bFound : Boolean;
begin
  OpenPictureDialog1.InitialDir := StoragePath;
  if OpenPictureDialog1.Execute then
  begin
    ClearWindow;
    DoSQLiteconnect;
    LoadDatabase;

    for iBrightCycle := 0 to 50 do
    begin
      Image1.Picture.LoadFromFile(OpenPictureDialog1.FileName);
      ChangeImageExposure(Image1.Picture.Bitmap, iBrightCycle * 5);
      Image1.Repaint;

      if not Assigned(FrameBitmap) then
      begin
        FrameBitmap := TBitmap.Create;
        FrameBitmap.PixelFormat := pf24bit;
      end;

      resizeframe := cvCreateImage(cvSize(1280,960), IPL_DEPTH_8U, 3); //SET XVGA INPUT TO
      MyfaceImage.MyInputImage := cvCreateImage(cvSize(640,480), IPL_DEPTH_8U, 3); //HD OUTPUT
      MyfaceImage.MyCapture := cvCreateCameraCapture(m_iCameraIndex);
      cvSetCaptureProperty(MyfaceImage.MyCapture, CV_CAP_PROP_FRAME_WIDTH, 640);
      cvSetCaptureProperty(MyfaceImage.MyCapture, CV_CAP_PROP_FRAME_HEIGHT, 480);

      FaceCascade := cvLoad(pCVChar(@FaceCascadeFile[1]), nil, nil, nil);

      if not Assigned(FaceCascade) then
      begin
        ShowMessage('ERROR: Unable to load cascade file:' + FaceCascadeFile);
        Halt;
      end;

      MyfaceImage.MyStorage := cvCreateMemStorage(0);
      MyfaceImage.MyInputImage := BitmapToIplImage(Image1.Picture.Bitmap);

      bFound:=DetectAndDraw(MyfaceImage);
      IplImage2Bitmap(MyfaceImage.MyInputImage, FrameBitmap);
      Image1.Picture.Graphic := FrameBitmap;
      ValidaReconhecimentoFace(bFound);
      if bFound then Break;
    end;
  end;
end;

procedure TfrmMain.Button4Click(Sender: TObject);
var
  bSave: TBitmap;
  jDest: TJPEGImage;
begin
  if (Edit1.Text='') then exit;
  if (Image2.Picture.Graphic = nil) then
    exit;
   Try
     ipllivefaceshow := CropIplImage(MyfaceImage.MyInputImage,CvRect(inputPt1.x,inputPt1.y,inputPt2.x-inputPt1.x,inputPt2.y-inputPt1.y));
     cvResize(ipllivefaceshow, iplcoloredfacesave, CV_INTER_LINEAR);
     cvCvTColor(iplcoloredfacesave, iplgrayfacesave, Cv_BGR2GRAY);
     bSave := Tbitmap.Create;
     bSave := CvImage2Bitmap(iplcoloredfacesave);
     iplImage2Bitmap(iplgrayfacesave,bSave);

     jDest := TJpegImage.Create;
     jDest.ProgressiveEncoding:=true;
     jDest.Scale := jsFullSize;
     jDest.Smoothing := True;
     jDest.Performance := jpBestQuality;
     jDest.Assign(bSave);

     sqliteQuery.SQL.Text := 'INSERT INTO tfaces(name,face) VALUES(:xname,:xface)';
     sqliteQuery.ParamByName('xname').Value := Edit1.Text;
     sqliteQuery.ParamByName('xface').AsBlob := JPEGToVariant(jDest);
     sqliteQuery.ExecSQL;
   Finally
     FreeAndNil(bSave);
     FreeAndNil(jDest);
     Edit1.Text:='';
     ClearWindow;
     LoadDatabase;
     Button1.Click;
   End;
end;

procedure TfrmMain.btnRostosClick(Sender: TObject);
begin
  formfaces:= Tformfaces.Create(nil);
  try
    formfaces.ShowModal();
  finally
    FreeAndNil(formfaces);
  end;
end;

procedure TfrmMain.Button6Click(Sender: TObject);
begin
  Button1.Click;
end;

procedure TfrmMain.btnPausarClick(Sender: TObject);
begin
  StopCapture;
  ClearWindow;
  btnPausar.Enabled:= False;
  SetLoadingVisible(False);
  btnRostos.Enabled:= True;
end;

procedure TfrmMain.ChangeImageExposure(src: TBitmap; k: Single);
var
  RGB: PRGBArray;
  i, x, y, RGBOffset: Integer;
  lut: array[0..255] of integer;
begin
  try
    for i := 0 to 255 do begin
      if k < 0 then
        lut[i]:= i - ((-Round((1 - Exp((i / -128)*(k / 128)))*256)*(i xor 255)) shr 8)
      else
        lut[i]:= i + ((Round((1 - Exp((i / -128)*(k / 128)))*256)*(i xor  255)) shr 8);
      if lut[i] < 0 then lut[i] := 0 else if lut[i] > 255 then lut[i] := 255;
    end;
    RGB := src.ScanLine[0];
    RGBOffset := Integer(src.ScanLine[1]) - Integer(RGB);
    for y := 0 to src.Height - 1 do begin
      for x := 0 to src.Width - 1 do begin
        RGB[x].R := LUT[RGB[x].R];
        RGB[x].G := LUT[RGB[x].G];
        RGB[x].B := LUT[RGB[x].B];
      end;
      RGB:= PRGBArray(Integer(RGB) + RGBOffset);
    end;
    RGB:= nil;
  except on E : Exception do
    begin
      Log.Add('Hora do Inicio do Log: '+ FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' - Erro no método - ChangeImageExposure '+ 'Classe de Erro: '+ E.ClassName +' Mensagem de erro: '+ E.Message + ' Linha do Erro: ' + E.StackTrace);
    end;
  end;
end;

procedure TfrmMain.LoadFaces(Sender: TObject);
begin
  Try
    DoSQLiteconnect;
    LoadDatabase;
  except on E : Exception do
    begin
      Log.Add('Hora do Inicio do Log: '+ FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' - Erro no método - LoadFaces '+ 'Classe de Erro: '+ E.ClassName +' Mensagem de erro: '+ E.Message + ' Linha do Erro: ' + E.StackTrace);
    end;
  end;
end;

procedure TfrmMain.VariantToStream(const v : olevariant; Stream : TMemoryStream);
var
  p : pointer;
begin
  Try
    try
      Stream.Position := 0;
      Stream.Size := VarArrayHighBound (v, 1) - VarArrayLowBound(v,  1) + 1;
      p := VarArrayLock (v);
      Stream.Write (p^, Stream.Size);
      VarArrayUnlock (v);
      Stream.Position := 0;
    except on E : Exception do
      begin
        Log.Add('Hora do Inicio do Log: '+ FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' - Erro no método - VariantToStream '+ 'Classe de Erro: '+ E.ClassName +' Mensagem de erro: '+ E.Message + ' Linha do Erro: ' + E.StackTrace);
      end;
    end;
  Finally
    p:= nil;
  End;
end;

procedure TfrmMain.ValidaReconhecimentoFace(const FaceDetected: boolean);
begin
   if FaceDetected then
   begin
     if not (lbName.Caption = '') then
     begin
       AtualizaImagemReconhecimento(tpGranted);
       SetLoadingVisible(False);
       SHowmessage('Acesso concedido');
       SetFoundFace(False);
       Button1.Click;
       lbName.Caption:= '';
       Edit1.Enabled:= False;
       Button4.Enabled:= False;
       Button6.Enabled:= False;
     end  else
     if (lbName.Caption = '') and (Image2.Picture.Graphic = nil) then
     begin
       AtualizaImagemReconhecimento(tpDenied);
       SetLoadingVisible(True);
       lbName.Font.Color:= Clred;
       lbName.Caption:= 'Rosto não identificado';
       lbName.Repaint;
       sleep(500);
       lbName.Caption:= '';
       Button1.Click;
     end else
     if Image2.Picture <> nil then
     begin
       AtualizaImagemReconhecimento(tpGranted);
       SetLoadingVisible(False);
       Edit1.Enabled:= True;
       Button4.Enabled:= True;
       Button6.Enabled:= True;
     end;
   end else
   begin
     AtualizaImagemReconhecimento(tpDenied);
     SetLoadingVisible(True);
     lbName.Font.Color:= Clred;
     lbName.Caption:= 'Rosto não identificado';
     lbName.Repaint;
     sleep(500);
     lbName.Caption:= '';
     Button1.Click;
   end;
end;

procedure TfrmMain.VariantToJPEGToBMP(aValue:OleVariant; var aJPEG:TJPEGImage; var aBMP:TBitmap);
var
   Stream : TMemoryStream;
begin
  try
    try
      Stream := TMemoryStream.Create;
      VariantToStream (aValue,Stream);
      aJPEG.LoadfromStream(Stream);
      aBMP.Assign(aJPEG);
    except on E : Exception do
      begin
        Log.Add('Hora do Inicio do Log: '+ FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' - Erro no método - VariantToJPEGToBMP '+ 'Classe de Erro: '+ E.ClassName +' Mensagem de erro: '+ E.Message + ' Linha do Erro: ' + E.StackTrace);
      end;
    end;
  finally
    aValue:=0;
    FreeAndNil(Stream);
  end;
end;


procedure TfrmMain.LimpaImageReconhecimento;
begin
  granted.Visible:= False;
  denied.Visible:= False;
  lbName.Font.Color:= clgray;
end;

procedure TfrmMain.LoadDatabase;
var
  dbFaces: pIplImage;
  xID:integer;
  xFace:OleVariant;
  jpgFace: TJpegImage;
  bmpFace: TBitmap;
  xname:string;
begin
  Try
    try
      sqliteQuery.SQL.Text := 'CREATE TABLE IF NOT EXISTS                          '+
                              '       tfaces(id INTEGER PRIMARY KEY AUTOINCREMENT, '+
                              '              name VARCHAR(25),                     '+
                              '              face MEDIUMBLOB) ;                    ';
      sqliteQuery.ExecSQL;
      sqliteQuery.SQL.Text := 'PRAGMA auto_vacuum = FULL';
      sqliteQuery.ExecSQL;

      sqliteQuery.SQL.Text := 'SELECT id,name,face FROM tfaces';
      sqliteQuery.Open;

      dbNumfaces := sqliteQuery.RecordCount;


      if (dbNumfaces=0) then Exit;

      jpgFace := TJpegImage.Create;
      bmpFace := TBitmap.Create;

      SetLength(vIdlist, dbNumfaces);
      SetLength(fimages, dbNumfaces);
      SetLength(flabels, dbNumfaces);
      setlength(fxnames, dbNumfaces);
      dbFaces := cvCreateImage(GlobalSize, IPL_DEPTH_8U, 1);
      dbNumfaces:=0;

      while not(sqliteQuery.Eof) do
      begin
        xID:=   sqliteQuery.FieldByName('id').AsInteger;
        xName:= sqliteQuery.FieldByName('name').AsString;
        xFace:= sqliteQuery.FieldByName('face').AsVariant;

        VariantToJPEGToBMP(xFace, jpgFace, bmpFace);

        dbFaces := ocv.utils.BitmapToIplImage(bmpFace);

        bmpFace.Canvas.StretchDraw(Rect(0, 0, bmpFace.Width-28, bmpFace.Height-28), bmpFace);
        oImagelface.Add(bmpFace,bmpFace);
        oNameslist.Add(xName);

        fimages[dbNumfaces] := cvCreateImage(GlobalSize, IPL_DEPTH_8U, 1);
        cvCvTColor(dbFaces, fimages[dbNumfaces], Cv_BGR2GRAY);
        flabels[dbNumfaces] := dbNumfaces;
        fxnames[dbNumfaces] := xName;
        vIdlist[dbNumfaces] := xID;

        inc(dbNumfaces);
        sqliteQuery.Next;
      end;
      sqliteQuery.Close;

      lbpface_id := TFaceRecognizer.createLBPHFaceRecognizer(1,8,8,8,69); //select2
      lbpface_id.Train(fimages,flabels);
    except on E : Exception do
      begin
        Log.Add('Hora do Inicio do Log: '+ FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' - Erro no método - LoadDatabase '+ 'Classe de Erro: '+ E.ClassName +' Mensagem de erro: '+ E.Message + ' Linha do Erro: ' + E.StackTrace);
      end;
    end;
  Finally
    FreeAndNil(jpgFace);
    FreeAndNil(bmpFace);
    cvReleaseImage(dbFaces);
    xFace:= Null;
    dbFaces:= nil;
  End;
end;

procedure TfrmMain.WMQueryEndSession(var Message: TMessage);
begin
  SessionEnding := True;
  Message.Result := 1;
end;

function TfrmMain.DoSQLiteConnect : boolean;
begin
  try
    if sqliteConn = nil then
      sqliteConn := TSQLConnection.Create(nil);
    sqliteConn.DriverName := 'Sqlite';
    sqliteConn.ConnectionName := 'SQLiteConnection';
    sqliteConn.VendorLib:='sqlite3.dll';
    sqliteConn.Params.Values['Database'] := ExtractFilePath(ParamStr(0)) + 'dataface.db';

    if sqliteQuery = nil then
      sqliteQuery := TSQLQuery.Create(nil);
    sqliteQuery.SQLConnection := sqliteConn;
    sqliteConn.LoginPrompt:= false;
    sqliteConn.Connected:= True;
    result:= True;
  except on E : Exception do
    Log.Add('Hora d Inicio do Log: '+ FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' - Erro no método - DoSQLiteConnect '+ 'Classe de Erro: '+ E.ClassName +' Mensagem de erro: '+ E.Message + ' Linha do Erro: ' + E.StackTrace);
  end;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(sqliteQuery);
  sqliteConn.Connected:= False;
  FreeAndNil(sqliteConn);
  FreeAndNil(Image1);
  FreeAndNil(Image2);
  FreeAndNil(FrameBitmap);
  SetLength(vIdlist, 0);
  SetLength(fimages, 0);
  SetLength(flabels, 0);
  setlength(fxnames, 0);
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if not SessionEnding then
  begin
    StopCapture;
    Halt;
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  ReadConfig;
  InitVariables;
  InitDB;
  InitPaths;
  LabelTimer.Caption := '';
  Timer1.Enabled := False;
  Log:= TStringList.Create;
//  EnumerateVideoInputDevices;
end;

procedure TfrmMain.CreateDataFile(const sFile : String);
begin
  CopyFile(PWideChar(ExtractFilePath(ParamStr(0))+'dbblank.db'),PWideChar(ExtractFilePath(ParamStr(0))+'dataface.db'), False);
end;

procedure TfrmMain.InitVariables;
begin
  try
    GlobalSize := cvSize(WORK_WIDTH, WORK_HEIGHT);
    cvInitFont(@font, CV_FONT_HERSHEY_COMPLEX, 0.8, 0.8, 0, 1, CV_AA);

    inComingfaces0 := cvCreateImage(GlobalSize, IPL_DEPTH_8U, 3); //3 because its original
    iplcoloredfacesave := cvCreateImage(GlobalSize, IPL_DEPTH_8U, 3); //3 because its original
    ipllivefaceshow := cvCreateImage(GlobalSize, IPL_DEPTH_8U, 3); //3 because its original
    LiveFacesToTest := cvCreateImage(GlobalSize, IPL_DEPTH_8U, 1); //1 because original to GRAY(BGR[0])
    iplgrayfacesave := cvCreateImage(GlobalSize, IPL_DEPTH_8U, 1); //1 because original to GRAY(BGR[0])

    oBitmapDisplay := TBitmap.Create;
    oBitmapDisplay.SetSize(WORK_WIDTH,WORK_HEIGHT);

    oNameslist := TStringList.Create;
    oImagelface := TimageList.Create(self);
    oImagelface.SetSize(WORK_WIDTH-28,WORK_HEIGHT-28);
  except on E : Exception do
    begin
      Log.Add('Hora do Inicio do Log: '+ FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' - Erro no método - LoadDatabase '+ 'Classe de Erro: '+ E.ClassName +' Mensagem de erro: '+ E.Message + ' Linha do Erro: ' + E.StackTrace);
    end;
  end;
end;

procedure TfrmMain.InitDB;
begin
  if not DoSqliteConnect then
     CreateDataFile('dataface.db');
  LoadDatabase;
end;

procedure TfrmMain.InitPaths;
begin
  FaceCascadeFile := ExtractFilePath(ParamStr(0)) +  'cascade\face.xmL';
  StoragePath     := ExtractFilePath(ParamStr(0)) +  'images\';
  ForceDirectories(StoragePath);
end;

procedure TfrmMain.StopCapture;
begin
  Application.OnIdle := nil;
  cvReleaseCapture(MyfaceImage.MyCapture);
  Timer1.Enabled:= False;
  FreeAndNil(FrameBitmap);
end;

procedure TfrmMain.StartCapture(camnum:integer);
begin
  try
    FrameBitmap := TBitmap.Create;
    FrameBitmap.PixelFormat := pf24bit;
    FrameBitmap.SetSize(640,480);
    xgetfrom := 'localcam';
    MyfaceImage.MyCapture := cvCreateCameraCapture(camnum);
    cvSetCaptureProperty(MyfaceImage.MyCapture, CV_CAP_PROP_FRAME_WIDTH, 640);
    cvSetCaptureProperty(MyfaceImage.MyCapture, CV_CAP_PROP_FRAME_HEIGHT, 480);
    FaceCascade := cvLoad(pCVChar(@FaceCascadeFile[1]), nil, nil, nil);
    if not Assigned(FaceCascade) then
    begin
      ShowMessage('ERROR: Unable to load cascade file:' + FaceCascadeFile);
      Halt;
    end;

    MyfaceImage.MyStorage:= cvCreateMemStorage(0);
    if Assigned(MyfaceImage.MyCapture) then
    begin
      resizeframe := cvCreateImage(cvSize(1280,960), IPL_DEPTH_8U, 3); //SET XVGA INPUT TO
      MyfaceImage.MyInputImage := cvCreateImage(cvSize(640,480), IPL_DEPTH_8U, 3); //HD OUTPUT
      Application.OnIdle := OnIdle;
    end else
    begin
      resizeframe := cvCreateImage(cvSize(1280,960), IPL_DEPTH_8U, 3); //SET XVGA INPUT TO
      MyfaceImage.MyInputImage := cvCreateImage(cvSize(640,480), IPL_DEPTH_8U, 3); //HD OUTPUT
      Exit;
    end;
  except on E : Exception do
    begin
      Log.Add('Hora do Inicio do Log: '+ FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' - Erro no método - StartCapture '+ 'Classe de Erro: '+ E.ClassName +' Mensagem de erro: '+ E.Message + ' Linha do Erro: ' + E.StackTrace);
    end;
  end;
end;

procedure TfrmMain.OnIdle(Sender: TObject; var Done: Boolean);
var
  bFound : Boolean;
  rand: string;
begin
  try
    GarbageCollector();
    SetFoundFace(False);
    Randomize();
    rand:= random(199999).ToString;
    MyfaceImage.MyInputImage := cvQueryFrame(MyfaceImage.MyCapture);
    if (not Assigned(MyfaceImage.MyInputImage)) then Application.OnIdle := nil
    else
    begin
      JustDetect() ;

      IplImage2Bitmap(MyfaceImage.MyInputImage, FrameBitmap);
      Image1.Picture.Graphic := FrameBitmap;

      Done := False;
      SavePictureDialog1.FileName := '';
      if mi_countprints = 5 then
      begin
        LabelTimer.Caption := '';
        Timer1.Enabled := False;
        if FDetected then
        begin
         SavePictureDialog1.InitialDir := StoragePath;
         SavePictureDialog1.FileName :=  StoragePath + rand + 'capture.bmp';
         Image1.Picture.SaveToFile(SavePictureDialog1.FileName);
        end;

        for var iBrightCycle := 0 to 50 do
        begin
          if not FDetected then Break;

          if iBrightCycle>0 then Image1.Picture.LoadFromFile(SavePictureDialog1.FileName);

          ChangeImageExposure(Image1.Picture.Bitmap, iBrightCycle * 5);
          Image1.Repaint;
          MyfaceImage.MyStorage := cvCreateMemStorage(0);
          resizeframe := BitmapToIplImage(Image1.Picture.Bitmap);
          cvResize(resizeframe, MyfaceImage.MyInputImage,  CV_INTER_NN);

          bFound:= DetectAndDraw(MyfaceImage);
          SetFoundFace(bfound);
          IplImage2Bitmap(MyfaceImage.MyInputImage, FrameBitmap);
          Image1.Picture.Graphic := FrameBitmap;
        end;

        Application.OnIdle := nil;
        ValidaReconhecimentoFace(FFoundFace);
       end;

      case cbExcluirImagem.State of
        cbChecked:
        begin
         if fileExists(SavePictureDialog1.FileName) then
           DeleteFile(SavePictureDialog1.FileName);
        end;
      end;
    end;
  except on E : Exception do
    begin
      Log.Add('Hora do Inicio do Log: '+ FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' - Erro no método - OnIdle '+ 'Classe de Erro: '+ E.ClassName +' Mensagem de erro: '+ E.Message + ' Linha do Erro: ' + E.StackTrace);
      Button1.Click;
    end;
  end;
end;

procedure TfrmMain.StreamToVariant (Stream : TMemoryStream; var v : OleVariant);
var
  p : pointer;
begin
  try
    v := VarArrayCreate ([0, Stream.Size - 1], varByte);
    p := VarArrayLock (v);
    Stream.Position := 0;
    Stream.Read (p^, Stream.Size);
    VarArrayUnlock (v);
    p:= nil ;
  except on E : Exception do
    begin
      Log.Add('Hora do Inicio do Log: '+ FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' - Erro no método - StreamToVariant '+ 'Classe de Erro: '+ E.ClassName +' Mensagem de erro: '+ E.Message + ' Linha do Erro: ' + E.StackTrace);
    end;
  end;
end;


procedure TfrmMain.Timer1Timer(Sender: TObject);
begin
  mi_countprints := mi_countprints + 1;
  LabelTimer.Caption := IntToStr(5-mi_countprints);
  LabelTimer.Repaint;
end;

procedure TfrmMain.GarbageCollector;
var
  MainHandle : THandle;
begin
  try
    MainHandle := OpenProcess(PROCESS_ALL_ACCESS, false, GetCurrentProcessID) ;
    SetProcessWorkingSetSize(MainHandle, $FFFFFFFF, $FFFFFFFF) ;
    CloseHandle(MainHandle) ;
  except on E : Exception do
    begin
      Log.Add('Hora do Inicio do Log: '+ FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' - Erro no método - GarbageCollector '+ 'Classe de Erro: '+ E.ClassName +' Mensagem de erro: '+ E.Message + ' Linha do Erro: ' + E.StackTrace);
      Button1.Click;
    end;
  end;
end;

function TfrmMain.JPEGToVariant(aJPEG : TJPEGImage) : OleVariant;
var
  Stream: TMemoryStream;
begin
  try
    try
      Stream := TMemoryStream.Create;
      aJPEG.SaveToStream(Stream);
      StreamToVariant(Stream, result);
    except on E : Exception do
      begin
        Log.Add('Hora do Inicio do Log: '+ FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' - Erro no método - JPEGToVariant '+ 'Classe de Erro: '+ E.ClassName +' Mensagem de erro: '+ E.Message + ' Linha do Erro: ' + E.StackTrace);
        Button1.Click;
      end;
    end;
  finally
    FreeAndNil(Stream);
  end;
end;

procedure TfrmMain.JustDetect;
var
  inputFace: pCvSeq;
begin
  Try
    if (MyfaceImage.MyInputImage = nil) or (MyfaceImage.MyStorage = nil) then Exit;

    inputFace := cvHaarDetectObjects(MyfaceImage.MyInputImage, FaceCascade, MyfaceImage.MyStorage, 1.1, 3,  0, cvSize(99, 99), cvSize(0, 0)); //CV_HAAR_SCALE_IMAGE
    cvClearMemStorage(MyfaceImage.MyStorage);

    SetDetected(inputFace.total <>  0);
    if inputFace.total = 0 then Exit;
  except  on E : Exception do
    begin
      Log.Add('Hora do Inicio do Log: '+ FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' - Erro no método - JustDetect '+ 'Classe de Erro: '+ E.ClassName +' Mensagem de erro: '+ E.Message + ' Linha do Erro: ' + E.StackTrace);
      Timer1.Enabled:= False;
      ClearWindow;
      Button1.Click;
    end;
  End;
end;

destructor TfrmMain.Destroy;
begin
  inherited;
  if Log <> nil then
    if Log.Count > 0  then
      Log.SaveToFile(ExtractFilePath(ParamStr(0)) +'\LOG'+FormatDateTime('ddmmyyyyhhnnss',Now())+'.txt') ;
end;

function TfrmMain.DetectAndDraw(const faceImage: pfaceImage) : Boolean;
var
  I: Integer;
  lab: Integer;
  iTotalFaceDetect : Integer;
  confidence: double;
  sAux : AnsiString;
  inputFace: pCvSeq;
  faceOutimage: pCvRect;
  inputFacePt1, inputFacePt2: TCvPoint;
begin
  GarbageCollector();
  try
    try
      if (faceImage.MyInputImage = nil) or (faceImage.MyStorage = nil) then Exit;
      inputFace := cvHaarDetectObjects(faceImage.MyInputImage, FaceCascade, faceImage.MyStorage,  1.1, 3, 0, cvSize(99, 99), cvSize(0, 0));
      cvClearMemStorage(faceImage.MyStorage);
      iTotalFaceDetect := inputFace.total;
      if inputFace.total = 0 then exit;
      for I := 1 to inputFace^.total do
      begin
        faceOutimage := pCvRect(cvGetSeqElem(inputFace, I));

        inputFacePt1.x := faceOutimage^.x;
        inputFacePt2.x := (faceOutimage^.x + faceOutimage^.width);
        inputFacePt1.y := faceOutimage^.y;
        inputFacePt2.y := (faceOutimage^.y + faceOutimage^.height);

        inputPt1.x := faceOutimage^.x + 13;
        inputPt2.x := (faceOutimage^.x + faceOutimage^.width) - 13;
        inputPt1.y := faceOutimage^.y + 26;
        inputPt2.y := (faceOutimage^.y + faceOutimage^.height);

        ipllivefaceshow := CropIplImage(faceImage.MyInputImage,CvRect(inputFacePt1.x{left},inputFacePt1.y{top},{right}inputFacePt2.x-inputFacePt1.x,{bottom}inputFacePt2.y-inputFacePt1.y));

        oBitmapDisplay := cvImage2Bitmap(ipllivefaceshow);
        image2.Picture.Bitmap := oBitmapDisplay;

        ipllivefaceshow := CropIplImage(faceImage.MyInputImage,CvRect(inputPt1.x,inputPt1.y,inputPt2.x-inputPt1.x,inputPt2.y-inputPt1.y));
        cvResize(ipllivefaceshow, inComingfaces0, CV_INTER_LINEAR);
        cvCvTColor(inComingfaces0, LiveFacesToTest, Cv_BGR2GRAY);
        if (dbNumfaces<1) then
        begin
          cvRectangle(faceImage.MyInputImage, inputFacePt1, inputFacePt2, CV_RGB(0, 0, 255), 2, 8, 0);
          ipllivefaceshow := CropIplImage(faceImage.MyInputImage,CvRect(inputPt1.x,inputPt1.y,inputPt2.x-inputPt1.x,inputPt2.y-inputPt1.y));
          cvResize(ipllivefaceshow, inComingfaces0, CV_INTER_LINEAR);
          cvCvTColor(inComingfaces0, LiveFacesToTest, Cv_BGR2GRAY);
          iplImage2Bitmap(LiveFacesToTest, oBitmapDisplay);
          Exit;
        end;

        confidence := 0;
        lbpface_id.predict(LiveFacesToTest,lab,confidence);
        if (lab = -1) then
        begin
          cvRectangle(faceImage.MyInputImage, inputFacePt1, inputFacePt2, CV_RGB(255, 0, 0), 2, 8, 0);
          cvPutText(faceImage.MyInputImage, 'Desconhecido(a) 0%', cvPoint(inputFacePt1.x, inputFacePt1.y - 20), @font, cvScalar(0, 255, 0));
        end
        else
        begin
          sAux := fxnames[lab] + ' ' + FormatFloat('0.0%', confidence);
          lbName.Font.Color:= clGreen;
          lbName.Caption := fxnames[lab];
          cvRectangle(faceImage.MyInputImage, inputFacePt1, inputFacePt2, CV_RGB(0, 255, 0), 2, 8, 0);
          cvPutText(faceImage.MyInputImage, PAnsiChar(sAux), cvPoint(inputFacePt1.x, inputFacePt1.y - 20), @font, cvScalar(0, 255, 0));
        end;

        iplImage2Bitmap(LiveFacesToTest, oBitmapDisplay);
        oBitmapDisplay.FreeImage;
        cvReleaseImage(ipllivefaceshow);
      end;

    except  on E : Exception do
      begin
        Log.Add('Hora do Inicio do Log: '+ FormatDateTime('dd/mm/yyyy hh:nn:ss', Now) + ' - Erro no método - DetectAndDraw '+ 'Classe de Erro: '+ E.ClassName +' Mensagem de erro: '+ E.Message + ' Linha do Erro: ' + E.StackTrace);
        Timer1.Enabled:= False;
      end;
    end;
  finally
    cvReleaseMemStorage(faceImage.MyStorage);
  end;
  Result:=iTotalFaceDetect > 0;
end;

procedure TfrmMain.ClearWindow;
begin
  MyfaceImage := nil;
  MyfaceImage := AllocMem(SizeOf(TfaceImage));

  Image1.Picture.Graphic := nil;
  Image2.Picture.Graphic := nil;
  Edit1.Text := '';
  Edit1.Font.Color := clWindowText;
  Timer1.Enabled:= False;
  LabelTimer.caption:= '';
end;

procedure TfrmMain.ReadConfig;
var
 oAppINI   : TInifile;
begin
  oAppINI := TIniFile.Create(ChangeFileExt(Application.ExeName,'.ini')) ;
  try
     m_iCameraIndex := oAppINI.ReadInteger('Camera','Index',0) ;
  finally
     FreeAndNil(oAppINI);
  end;
end;

procedure TfrmMain.SetDetected(const Value: boolean);
begin
  FDetected := Value;
end;

procedure TfrmMain.SetFoundFace(const Value: boolean);
begin
  FFoundFace := Value;
end;

procedure TfrmMain.SetLoadingVisible(const Value: Boolean);
begin
  PnlLoading.Visible:= value;
end;

procedure TfrmMain.SetLog(const Value: TStringlist);
begin
  FLog := Value;
end;

//  In the Futura

//procedure TfrmMain.EnumerateVideoInputDevices;
//const
//  IID_IPropertyBag          : TGUID = '{55272A00-42CB-11CE-8135-00AA004BB851}';
//var
//  LDevEnum : ICreateDevEnum;
//  ppEnumMoniker    : IEnumMoniker;
//  pceltFetched : ULONG;
//  Moniker    : IMoniker;
//  PropBag    : IPropertyBag;
//  pvar       : olevariant;
//  hr         : HRESULT;
//  i          : integer;
//begin
//  CocreateInstance(CLSID_SystemDeviceEnum, nil, CLSCTX_INPROC, IID_ICreateDevEnum, LDevEnum);
//  hr := LDevEnum.CreateClassEnumerator(CLSID_VideoInputDeviceCategory, ppEnumMoniker, 0);
//  if (hr = S_OK) then
//  begin
//    while(ppEnumMoniker.Next(1, Moniker, @pceltFetched) = S_OK) do
//      begin
//        Moniker.BindToStorage(nil, nil, IID_IPropertyBag, PropBag);
//        if PropBag.Read('FriendlyName', pvar, nil) = S_OK then
//          cbCameras.Items.Add( 'Nome: - ' +String(pvar));
//        PropBag := nil;
//        Moniker := nil;
//      end;
//  end;
//  ppEnumMoniker :=nil;
//  LDevEnum :=nil;
//  cbCameras.ItemIndex:= 0;
//end;


end.
