unit ocv.cls.contrib;

interface
Uses
  ocv.core.types_c;

const
  DBL_MAX = 1.7976931348623157E+308;
  opencv_classes_lib = 'opencv_face2413.dll';

type
  TInputArrayOfIplImage = Array of pIplImage;
  TInputArrayOfInteger = Array of integer;

  xCommon = class(TInterfacedObject)
  protected
    ocvdata: Pointer;
  public
    constructor Create(const bindata: Pointer);
end;

IFaceRecognizer = interface
    // Trains a FaceRecognizer.
    // CV_WRAP virtual void train(InputArrayOfArrays src, InputArray labels) = 0;
    procedure train(src: TInputArrayOfIplImage; labels: TInputArrayOfInteger);

    // Updates a FaceRecognizer.
    // CV_WRAP void update(InputArrayOfArrays src, InputArray labels);
    procedure update(src: TInputArrayOfIplImage; labels: TInputArrayOfInteger);

    // Predicts the label and confidence for a given sample.
    // CV_WRAP virtual void predict(InputArray src, CV_OUT int &label, CV_OUT double &confidence) const = 0;
    procedure predict(src: pIplImage; Var lab: Integer; var confidence: double);

    // Serializes this object to a given filename.
    // CV_WRAP virtual void save(const string& filename) const;
    procedure save(const filename: string);

    // Deserializes this object from a given filename.
    // CV_WRAP virtual void load(const string& filename);
    procedure load(const filename: string);
end;

  TFaceRecognizer = class(xCommon, IFaceRecognizer)
  public
    // CV_EXPORTS_W Ptr<FaceRecognizer> createEigenFaceRecognizer(int num_components = 0, double threshold = DBL_MAX);
    constructor createEigenFaceRecognizer(num_components: Integer = 0; threshold: double = DBL_MAX);
    // CV_EXPORTS_W Ptr<FaceRecognizer> createFisherFaceRecognizer(int num_components = 0, double threshold = DBL_MAX);
    constructor createFisherFaceRecognizer(num_components: Integer = 0; threshold: double = DBL_MAX);
    // CV_EXPORTS_W Ptr<FaceRecognizer> createLBPHFaceRecognizer(int radius=1, int neighbors=8,int grid_x=8, int grid_y=8, double threshold = DBL_MAX);
    constructor createLBPHFaceRecognizer(radius: Integer = 1; neighbors: Integer = 8; grid_x: Integer = 8; grid_y: Integer = 8; threshold: double = DBL_MAX);

    destructor Destroy; override;

    procedure train(src: TInputArrayOfIplImage; labels: TInputArrayOfInteger);
    procedure update(src: TInputArrayOfIplImage; labels: TInputArrayOfInteger);
    procedure predict(src: pIplImage; Var lab: Integer; var confidence: double);
    procedure save(const filename: string);
    procedure load(const filename: string);
  end;


implementation


constructor xCommon.Create(const bindata: Pointer);
begin
  ocvdata := bindata;
end;


// CV_EXPORTS_W Ptr<FaceRecognizer> createEigenFaceRecognizer(int num_components = 0, double threshold = DBL_MAX);
function Create_EigenFaceRecognizer(num_components: Integer = 0; threshold: double = DBL_MAX): Pointer; stdcall;
  external opencv_classes_lib name '_Create_EigenFaceRecognizer@12';

// CV_EXPORTS_W Ptr<FaceRecognizer> createFisherFaceRecognizer(int num_components = 0, double threshold = DBL_MAX);
function Create_FisherFaceRecognizer(num_components: Integer = 0; threshold: double = DBL_MAX): Pointer; stdcall;
  external opencv_classes_lib name '_Create_FisherFaceRecognizer@12';

// CV_EXPORTS_W Ptr<FaceRecognizer> createLBPHFaceRecognizer(int radius=1, int neighbors=8,int grid_x=8, int grid_y=8, double threshold = DBL_MAX);
function Create_LBPHFaceRecognizer(radius: Integer = 1; neighbors: Integer = 8; grid_x: Integer = 8; grid_y: Integer = 8; threshold: double = DBL_MAX): Pointer; stdcall;
  external opencv_classes_lib name '_Create_LBPHFaceRecognizer@24';

procedure _DestroyFaceRecognizer(const E: Pointer); stdcall;
external opencv_classes_lib name '_DestroyFaceRecognizer@4';

procedure DestroyFaceRecognizer(const M: Pointer); stdcall;
external opencv_classes_lib name '_DestroyFaceRecognizer@4';

procedure FaceRecognizerLoad(const M: Pointer; filename: PAnsiChar); stdcall;
external opencv_classes_lib name '_FaceRecognizerLoad@8';

procedure FaceRecognizerSave(const M: Pointer; filename: PAnsiChar); stdcall;
external opencv_classes_lib name '_FaceRecognizerSave@8';

procedure pFaceRecognizerPredict(const M: Pointer; scr: pIplImage; var _label: Integer; var confidence: double); stdcall;
external opencv_classes_lib name '_FaceRecognizerPredict2@16';

procedure FaceRecognizerTrain(const M: Pointer; const n: Integer; scr: Pointer; labels: Pointer); stdcall;
external opencv_classes_lib name '_FaceRecognizerTrain@16';

procedure FaceRecognizerUpdate(const M: Pointer; const n: Integer; scr: Pointer; labels: Pointer); stdcall;
external opencv_classes_lib name '_FaceRecognizerUpdate@16';

{ TFaceRecognizer }
constructor TFaceRecognizer.createEigenFaceRecognizer(num_components: Integer; threshold: double);
begin
  inherited Create(Create_EigenFaceRecognizer(num_components, threshold));
end;

constructor TFaceRecognizer.createFisherFaceRecognizer(num_components: Integer; threshold: double);
begin
  inherited Create(Create_FisherFaceRecognizer(num_components, threshold));
end;

constructor TFaceRecognizer.createLBPHFaceRecognizer(radius, neighbors, grid_x, grid_y: Integer; threshold: double);
begin
  inherited Create(Create_LBPHFaceRecognizer(radius, neighbors, grid_x, grid_y, threshold));
end;

destructor TFaceRecognizer.Destroy;
begin
  if Assigned(ocvdata) then
  begin
    _DestroyFaceRecognizer(ocvdata);
    ocvdata := nil;
  end;
  inherited;
end;

procedure TFaceRecognizer.load(const filename: string);
begin
  FaceRecognizerLoad(ocvdata, pAnsiChar(@(AnsiString(filename)[1])));
end;

procedure TFaceRecognizer.predict(src: pIplImage; var lab: Integer; var confidence: double);
begin
  pFaceRecognizerPredict(ocvdata, src, lab, confidence);
end;

procedure TFaceRecognizer.save(const filename: string);
begin
  FaceRecognizerSave(ocvdata, pAnsiChar(AnsiString(filename)));
end;

procedure TFaceRecognizer.train(src: TInputArrayOfIplImage; labels: TInputArrayOfInteger);
begin
  FaceRecognizerTrain(ocvdata, Length(src), @src[0], @labels[0]);
end;

procedure TFaceRecognizer.update(src: TInputArrayOfIplImage; labels: TInputArrayOfInteger);
begin
  FaceRecognizerUpdate(ocvdata, Length(src), @src[0], @labels[0]);
end;

end.
