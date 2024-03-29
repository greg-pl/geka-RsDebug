unit RegMemUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, MemFrameUnit, RmtChildUnit,IniFiles,
  ImgList, ComCtrls, ActnList, Menus, ToolWin,
  MapParserUnit,
  ProgCfgUnit,
  ToolsUnit,
  RsdDll,
  CommonDef,
  AnalogFrameUnit;
  // CfgFrameUnit, CFrameAnalogUnit;


type
  TRegMemType = (rmANALOGINP, rmREGISTERS);
  TRegMemForm = class(TChildForm)
    MemFrame: TAnalogFrame;
    AutoRepTimer: TTimer;
    GridPopUp: TPopupMenu;
    ReadMemBtn: TToolButton;
    AutoRepBtn: TToolButton;
    AutoRepTmEdit: TComboBox;
    Label5: TLabel;
    AdresBox: TComboBox;
    SizeBox: TComboBox;
    Label4: TLabel;
    Label2: TLabel;
    SaveMemBtn: TToolButton;
    FillFFBtn: TToolButton;
    ToolButton4: TToolButton;
    ReadMemAct: TAction;
    AutoRepAct: TAction;
    SaveBufAct: TAction;
    WrMemBtn: TToolButton;
    WrMemAct: TAction;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    RdBackAct: TAction;
    RdNextAct: TAction;
    FillFFAct: TAction;
    FillZeroAct: TAction;
    Fill00Btn: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    SaveMemAct: TAction;
    LoadMemAct: TAction;
    ToolButton12: TToolButton;
    ToolButton14: TToolButton;
    SaveMemTxtAct: TAction;
    FillxxBtn: TToolButton;
    FillValueEdit: TEdit;
    FillxxAct: TAction;
    ToolButton1: TToolButton;
    ExMemAct: TAction;
    ExchAdresBox: TComboBox;
    Label1: TLabel;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure ComboBoxExit(Sender: TObject);
    procedure AutoRepTimerTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure ReadMemActExecute(Sender: TObject);
    procedure ReadMemActUpdate(Sender: TObject);
    procedure MemFrameShowTypePageCtrlChange(Sender: TObject);
    procedure AdresBoxChange(Sender: TObject);
    procedure AutoReadActExecute(Sender: TObject);
    procedure AutoReadActUpdate(Sender: TObject);
    procedure SaveBufActExecute(Sender: TObject);
    procedure WrMemActExecute(Sender: TObject);
    procedure FillZeroActExecute(Sender: TObject);
    procedure FillFFActExecute(Sender: TObject);
    procedure SaveMemActExecute(Sender: TObject);
    procedure RdBackActExecute(Sender: TObject);
    procedure RdNextActExecute(Sender: TObject);
    procedure LoadMemActExecute(Sender: TObject);
    procedure AreaBoxChange(Sender: TObject);
    procedure SaveMemTxtActExecute(Sender: TObject);
    procedure FillxxActExecute(Sender: TObject);
    procedure ExMemActExecute(Sender: TObject);
  private
    MemType   : TRegMemType;
    function  OnToValueProc(MemName : string; Buf : pByte; TypeSign:char; var Val:OleVariant): integer;
    function  OnToBinProc(MemName : string; Mem : pbyte; Size:integer; TypeSign:char; Val:OleVariant): integer;
    function  ReadMem : TStatus;
    function  WriteMem : TStatus;
    function  ExchangeMem : TStatus;
    procedure GetFromText(var Adr : cardinal; var ShowAdr : cardinal; var Size : cardinal);
  protected
    function  ReadPtrValue(A : cardinal): cardinal;
    function  GetPhAdr(Adr : cardinal):cardinal;
  public
    procedure SaveToIni(Ini : TDotIniFile; SName : string); override;
    procedure LoadFromIni(Ini : TDotIniFile; SName : string); override;
    procedure SettingChg; override;
    procedure ReloadMapParser; override;
    function  GetDefaultCaption : string; override;
    procedure doParamsVisible(vis : boolean); override;
    procedure ShowMem(Adr : integer);
    procedure SetMemType(mtype : TRegMemType);
  end;

var
  RegMemForm: TRegMemForm;

implementation


{$R *.dfm}

Const
  smfH8_RESET  = 0;
  smfDSP_RESET = 6;
  RegMemName : array[TRegMemType] of string = ('ANALOG_INP','REGISTERS');

function GetMemType(s : string): TRegMemType;
begin
  Result := rmREGISTERS;
  if s = RegMemName[rmANALOGINP] then
    Result := rmANALOGINP;
end;


procedure TRegMemForm.FormCreate(Sender: TObject);
begin
  inherited;
  MemFrame.OnToValue  := OnToValueProc;
  MemFrame.OnToBin := OnToBinProc;
  MemFrame.MemSize := $100;
  MemType := rmREGISTERS;
end;

procedure TRegMemForm.SetMemType(mtype : TRegMemType);
begin
  MemType := mtype;
  ShowCaption;
  if MemType = rmANALOGINP then
  begin
    WrMemBtn.Visible := false;
    SaveMemBtn.Visible := false;
    FillFFBtn.Visible := false;
    Fill00Btn.Visible := false;
    FillxxBtn.Visible := false;
    FillValueEdit.Visible := false;
  end;
end;


type
  PByteAr = ^TByteAr;
  TByteAr = array[0..7] of byte;


function TRegMemForm.OnToBinProc(MemName : string; Mem : pbyte; Size:integer; TypeSign:char; Val:OleVariant): integer;

procedure SetDWord(Mem : pbyte; W :cardinal);
begin
  if AreaDefItem.ByteOrder=boBig then
  begin
    PByteAr(Mem)^[0] := byte(w shr 24);
    PByteAr(Mem)^[1] := byte(w shr 16);
    PByteAr(Mem)^[2] := byte(w shr 8);
    PByteAr(Mem)^[3] := byte(w);
  end
  else
    pCardinal(Mem)^ := w;
end;

procedure SetWord(Mem : pbyte; W :cardinal);
begin
  if AreaDefItem.ByteOrder=boBig then
  begin
    PByteAr(Mem)^[0] := byte(w shr 8);
    PByteAr(Mem)^[1] := byte(w);
  end
  else
    pWord(Mem)^ := w;
end;

var
  W : word;
  D : cardinal;
  f : Single;
begin
  case  TypeSign of
  'B' : PByteAr(Mem)^[0] := Val;
  'W' : begin
          W :=Val;
          SetWord(Mem,W);
        end;
  'D' : begin
          D :=Val;
          SetDWord(Mem,D);
        end;
  'F' : begin
          f := Val;
          D := PCardinal(addr(f))^;
          SetDWord(Mem,D);
        end;
  end;
  Result := 0;
end;


function TRegMemForm.OnToValueProc(MemName : string; Buf : pByte; TypeSign:char; var Val:OleVariant): integer;

function GetDWord(Buf : pByte):Cardinal;
begin
  if AreaDefItem.ByteOrder=boBig then
  begin
    Result := (Buf^) shl 24;
    inc(Buf);
    Result := Result or ((Buf^) shl 16);
    inc(Buf);
    Result := Result or ((Buf^) shl 8);
    inc(Buf);
    Result  := Result or Buf^;
  end
  else
    Result  := pCardinal(Buf)^;
end;

function GetWord(Dt : pbyte): word;
begin
  if AreaDefItem.ByteOrder=boBig then
  begin
    Result := (Dt^) shl 8;
    inc(Dt);
    Result  := result or Dt^;
  end
  else
    Result := pWord(Dt)^;
end;

type
  pDouble = ^Double;
var
  X : Cardinal;
  XT :  array[0..1] of cardinal;
begin
  Result := 0;
  case  TypeSign of
  'B' : Val := PByteAr(buf)^[0];
  'W' : Val := GetWord(buf);
  'D' : Val := GetDWord(buf);
  'F' : begin
          X := GetDWord(buf);
          Val := psingle(addr(X))^;
        end;
  'E' : begin
          XT[0] := GetDWord(buf);
          inc(buf,4);
          XT[1] := GetDWord(buf);
          Val := pdouble(addr(XT))^;
        end;
  else
    Val := 0;
    Result := 1;
  end;
end;

function TRegMemForm.GetPhAdr(Adr : cardinal):cardinal;
begin
  Result := AreaDefItem.GetPhAdr(Adr);
end;

function  TRegMemForm.ReadPtrValue(A : cardinal): cardinal;
var
  Size : integer;
  tab  : array[0..3] of byte;
begin
  case AreaDefItem.PtrSize of
  ps8  : Size:=1;
  ps16 : Size:=2;
  ps32 : Size:=4;
  else
    raise Exception.Create('Nieproawidlowa wartosc PtrSize');
  end;
  if Dev.ReadMem(Handle,tab[0],A,Size)<>stOK then
    raise Exception.Create('Blad odczytu wskaznika');

  case AreaDefItem.PtrSize of
  ps8  : Result := Tab[0];
  ps16 : Result := GetWord(@Tab,AreaDefItem.ByteOrder);
  ps32 : Result := GetDWord(@Tab,AreaDefItem.ByteOrder);
  else
    raise Exception.Create('Nieproawidlowa wartosc PtrSize');
  end;
end;


procedure TRegMemForm.GetFromText(var Adr : cardinal; var ShowAdr : cardinal; var Size : cardinal);
var
  S   : cardinal;
  A   : cardinal;
begin
  A := MapParser.StrToAdr(AdresBox.Text);
  S := MapParser.StrToAdr(SizeBox.Text);
  ShowAdr := A-1;
  Adr  := A;
  Size := S;
end;

function TRegMemForm.ReadMem : TStatus;
var
  Adr     : cardinal;
  ShowAdr : cardinal;
  Size    : cardinal;
  TT      : cardinal;
begin
  inherited;
  GetFromText(Adr,ShowAdr,Size);
  MemFrame.MemTypeStr   := AreaDefItem.Name;
  MemFrame.MemSize      := Size;
  MemFrame.SrcAdr       := ShowAdr;

  if Size<>0 then
  begin
    //MemFrame.ClrData;
    TT := GetTickCount;
    case MemType of
    rmANALOGINP:
      Result:=Dev.RdAnalogInp(Handle,MemFrame.MemBuf[0],Adr,Size);
    rmREGISTERS:
      Result:=Dev.RdReg(Handle,MemFrame.MemBuf[0],Adr,Size);
    else
       Result := stNoImpl;
    end;

    TT := GetTickCount-TT;
    if Result=stOK then
    begin
      if TT<>0 then
        DoMsg(Format('RdMem v=%.2f[kB/sek]',[(size/1024)/(TT/1000.0)]))
      else
        DoMsg('RdMem OK');
      MemFrame.SetNewData;
    end
    else
    begin
      DoMsg(Dev.GetErrStr(Result));
      MemFrame.ClrData;
    end;
  end
  else
    Result:=-1;
end;

function TRegMemForm.WriteMem : TStatus;
var
  Adr     : cardinal;
  ShowAdr : cardinal;
  Size    : cardinal;
begin
  GetFromText(Adr,ShowAdr,Size);
  Result:=Dev.WrMultiReg(Handle,MemFrame.MemBuf[0],Adr,Size);
  DoMsg(Dev.GetErrStr(Result));
end;

function  TRegMemForm.ExchangeMem : TStatus;
var
  Adr     : cardinal;
  WrAdr   : cardinal;
  ShowAdr : cardinal;
  Size    : cardinal;
begin
  AddToList(ExchAdresBox);
  GetFromText(Adr,ShowAdr,Size);
  WrAdr := MapParser.StrToAdr(ExchAdresBox.Text);
  Result:=Dev.ReadWriteRegs(Handle,MemFrame.MemBuf[0],Adr,Size,MemFrame.MemBuf[0],WrAdr,Size);
  if Result=stOK then
  begin
    DoMsg('ExchangeMem OK');
    MemFrame.SetNewData;
  end
  else
  begin
    DoMsg(Dev.GetErrStr(Result));
    MemFrame.ClrData;
  end;
end;

procedure TRegMemForm.ReadMemActUpdate(Sender: TObject);
begin
  (Sender  as TAction).Enabled := IsConnected and not(AutoRepAct.Checked);
end;

procedure TRegMemForm.AutoReadActUpdate(Sender: TObject);
begin
 (Sender  as TAction).Enabled := IsConnected
end;


procedure TRegMemForm.ReadMemActExecute(Sender: TObject);
begin
  inherited;
  AddToList(AdresBox);
  AddToList(SizeBox);
  AddToList(AutoRepTmEdit);
  ReadMem;
end;


procedure TRegMemForm.RdBackActExecute(Sender: TObject);
var
  Adr     : cardinal;
  Size    : cardinal;
  ShowAdr : cardinal;
  RegSize : cardinal;
begin
  inherited;
  RegSize := 2;
  GetFromText(Adr,ShowAdr,Size);
  Adr := ShowAdr-(Size div RegSize);
  AdresBox.Text := '0x'+IntToHex(Adr,8);
  ReadMem;
end;


procedure TRegMemForm.RdNextActExecute(Sender: TObject);
var
  Adr     : cardinal;
  Size    : cardinal;
  RegSize : cardinal;
  ShowAdr : cardinal;
begin
  inherited;
  RegSize:=2;
  GetFromText(Adr,ShowAdr,Size);
  Adr := ShowAdr+(Size div RegSize);
  AdresBox.Text := '0x'+IntToHex(Adr,8);
  ReadMem;
end;

procedure TRegMemForm.WrMemActExecute(Sender: TObject);
begin
  inherited;
  WriteMem;
  MemFrame.SetNewData;
end;

procedure TRegMemForm.ExMemActExecute(Sender: TObject);
begin
  inherited;
  ExchangeMem;
  MemFrame.SetNewData;
end;



procedure TRegMemForm.FillZeroActExecute(Sender: TObject);
begin
  inherited;
  MemFrame.FillZero;
end;

procedure TRegMemForm.FillFFActExecute(Sender: TObject);
begin
  inherited;
  MemFrame.FillOnes;
end;

procedure TRegMemForm.FillxxActExecute(Sender: TObject);
var
  a : cardinal;
begin
  inherited;
  MapParser.StrToCInt(FillValueEdit.Text,a);
  MemFrame.Fill(a);
end;



procedure TRegMemForm.SaveBufActExecute(Sender: TObject);
var
  i   : Cardinal;
  st      : TStatus;
  Adr     : cardinal;
  BufAdr  : cardinal;
begin
  BufAdr := MapParser.StrToAdr(AdresBox.Text);
  try
    i := 0;
    while i<MemFrame.MemSize do
    begin
      if MemFrame.MemState[i]=csModify then
      begin
        Adr := GetPhAdr(BufAdr)+i;
        st := Dev.WrReg(Handle,Adr,MemFrame.MemBuf[i]);
        DoMsg(Format('WriteMem, adr=0x%X  :%s',[Adr,Dev.GetErrStr(st)]));
        MemFrame.MemState[i] := csFull;
      end;
      inc(i);
    end;
    MemFrame.PaintActivPage;
  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
    end;
  end;
end;

procedure TRegMemForm.ComboBoxExit(Sender: TObject);
begin
  inherited;
  AddToList(Sender as TComboBox);
end;

procedure TRegMemForm.AutoReadActExecute(Sender: TObject);
begin
  inherited;
  (Sender as Taction).Checked := not (Sender as Taction).Checked;
  AutoRepTimer.Enabled := (Sender as Taction).Checked;
  try
    AutoRepTimer.Interval := StrToInt(AutoRepTmEdit.Text);
  except
    ShowMessage('�le wprowadzony czas repetycji');
  end;
end;

procedure TRegMemForm.AutoRepTimerTimer(Sender: TObject);
begin
  inherited;
  AutoRepTimer.Enabled:=false;
  if ReadMem=stOk then
    AutoRepTimer.Enabled:=True
  else
    AutoRepAct.Checked := false;
end;

procedure TRegMemForm.SaveToIni(Ini : TDotIniFile; SName : string);
begin
  inherited;
  Ini.WriteString(SName,'MemType',RegMemName[MemType]);
  Ini.WriteString(SName,'Adr',AdresBox.Text);
  Ini.WriteString(SName,'Adrs',AdresBox.Items.CommaText);
  Ini.WriteString(SName,'ExAdr',ExchAdresBox.Text);
  Ini.WriteString(SName,'ExAdrs',ExchAdresBox.Items.CommaText);
  Ini.WriteString(SName,'Size',SizeBox.Text);
  Ini.WriteString(SName,'Sizes',SizeBox.Items.CommaText);
  Ini.WriteString(SName,'RepTime',AutoRepTmEdit.Text);
  Ini.WriteString(SName,'RepTimes',AutoRepTmEdit.Items.CommaText);
  Ini.WriteInteger(SName,'ViewPage',MemFrame.ActivPage);
  Ini.WriteString(SName,'FillValue',FillValueEdit.Text);
  MemFrame.SaveToIni(Ini,SName);
end;

procedure TRegMemForm.LoadFromIni(Ini : TDotIniFile; SName : string);

begin
  inherited;
  SetMemType(GetMemType(Ini.ReadString(SName,'MemType',RegMemName[MemType])));
  AdresBox.Text        := Ini.ReadString(SName,'Adr','1');
  AdresBox.Items.CommaText:=Ini.ReadString(SName,'Adrs','1,101');
  SizeBox.Text         := Ini.ReadString(SName,'Size','100');
  SizeBox.Items.CommaText :=Ini.ReadString(SName,'Sizes','10 32 100');
  FillValueEdit.Text   := Ini.ReadString(SName,'FillValue','0x01');
  ExchAdresBox.Text := Ini.ReadString(SName,'ExAdr','1');
  ExchAdresBox.Items.CommaText := Ini.ReadString(SName,'ExAdrs','1 101');
  AutoRepTmEdit.Items.CommaText := Ini.ReadString(SName,'RepTimes','');
  MemFrame.ActivPage := Ini.ReadInteger(SName,'ViewPage',0);
  MemFrame.LoadFromIni(Ini,SName);
  ShowCaption;

end;

procedure TRegMemForm.FormActivate(Sender: TObject);
begin
  inherited;
  ReloadMapParser;
end;


procedure TRegMemForm.ReloadMapParser;
begin
  inherited;
end;

procedure TRegMemForm.SettingChg;
begin
  inherited;
end;


procedure TRegMemForm.ShowMem(Adr : integer);
begin
  AdresBox.Text := MapParser.IntToVarName(Adr);
  ReadMemAct.Execute;
  ShowParamAct.Execute;
end;


procedure TRegMemForm.AreaBoxChange(Sender: TObject);
begin
  inherited;
  MemFrame.Refresh;
end;

procedure TRegMemForm.MemFrameShowTypePageCtrlChange(Sender: TObject);
begin
  inherited;
  ShowCaption;
end;

procedure TRegMemForm.AdresBoxChange(Sender: TObject);
begin
  inherited;
  ShowCaption;
end;

function  TRegMemForm.GetDefaultCaption : string;
begin
  Result :=  RegMemName[MemType]+' : ' +AdresBox.Text+'('+MemFrame.ShowTypePageCtrl.ActivePage.Caption+')'
end;

procedure TRegMemForm.doParamsVisible(vis : boolean);
begin
  inherited;
  MemFrame.doParamVisible(vis);
end;


procedure TRegMemForm.SaveMemActExecute(Sender: TObject);
var
  Dlg : TSaveDialog;
  Fname : string;
  Strm  : TmemoryStream;
begin
  inherited;
  Fname := '';
  Dlg := TSaveDialog.Create(self);
  try
    Dlg.DefaultExt := '.bin';
    Dlg.Filter := 'pliki binarne|*.bin|Wszystkie pliki|*.*';
    Dlg.Options := Dlg.Options +[ofOverwritePrompt];
    if Dlg.Execute then
      Fname :=Dlg.FileName;
  finally
    Dlg.Free;
  end;
  if Fname<>'' then
  begin
    Strm := TmemoryStream.Create;
    try
      Strm.Write(MemFrame.MemBuf[0],MemFrame.MemSize);
      Strm.SaveToFile(Fname);
    finally
      Strm.Free;
    end;
  end;
end;

procedure TRegMemForm.LoadMemActExecute(Sender: TObject);
var
  Dlg   : TOpenDialog;
  Fname : string;
  Strm  : TmemoryStream;
begin
  inherited;
  Fname := '';
  Dlg := TOpenDialog.Create(self);
  try
    Dlg.DefaultExt := '.bin';
    Dlg.Filter := 'pliki binarne|*.bin|Wszystkie pliki|*.*';
    if Dlg.Execute then
      Fname :=Dlg.FileName;
  finally
    Dlg.Free;
  end;
  if Fname<>'' then
  begin
    Strm := TmemoryStream.Create;
    try
      Strm.LoadFromFile(Fname);
      MemFrame.MemSize := Strm.Size;
      Strm.Read(MemFrame.MemBuf[0],MemFrame.MemSize);
      MemFrame.SetNewData;
      SizeBox.Text := Format('0x%X',[MemFrame.MemSize]);
      AddToList(SizeBox);

      DoMsg(Format('Wczytano %u [0x%X] bajt�w',[MemFrame.MemSize,MemFrame.MemSize]));
    finally
      Strm.Free;
    end;
  end;
end;






procedure TRegMemForm.SaveMemTxtActExecute(Sender: TObject);
var
  Dlg : TSaveDialog;
  Fname : string;
  SL  : TStringList;
begin
  inherited;
  Fname := '';
  Dlg := TSaveDialog.Create(self);
  try
    Dlg.DefaultExt := '.txt';
    Dlg.Filter := 'pliki textowe|*.txt|Wszystkie pliki|*.*';
    Dlg.Options := Dlg.Options +[ofOverwritePrompt];
    if Dlg.Execute then
      Fname :=Dlg.FileName;
  finally
    Dlg.Free;
  end;
  if Fname<>'' then
  begin
    SL := TStringList.Create;
    try
      MemFrame.CopyToStringList(SL);
      SL.SaveToFile(Fname);
    finally
      SL.Free;
    end;
  end;
end;



end.
