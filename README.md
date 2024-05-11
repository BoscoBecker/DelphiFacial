
![image](https://github.com/BoscoBecker/DelphiFacial/assets/6303278/0ad0e398-78d9-4404-b8b4-1dff65b1441d)


## Reconhecimento Facial usando Opencv  - No Dependencies Need

Adicionar no Library path  "/Source"
Imagens reconhecidas ficam salvas em um banco SQLITE  "Win32/Debug"

## OPENCV
DLL's do OPENCV precisam estar no mesmo diretório do Exe, assim como a dll SQLITE

## Haarcascade
Precisa estar no diretório Win32/Debug/Cascade

## Câmera
Câmera, existe um arquivo de configuração para informar qual câmera usar, caso tenha mais de uma.

``` pascal

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
```

Todo projeto já está na estrutura para se usado.
