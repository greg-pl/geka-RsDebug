unit BinaryMemUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Buttons, BinaryFrameUnit, RmtChildUnit,IniFiles,
  ImgList, ComCtrls, ActnList, Menus, ToolWin,
  MapParserUnit,
  ProgCfgUnit,
  ToolsUnit,
  RsdDll,
  Grids, 
  CommonDef,
  AnalogFrameUnit;


type
  TBinaryMemType = (bmBINARYINP, bmCOILS);
  TBinaryMemForm = class(TChildForm)
    MemFrame: TBinaryFrame;
    AutoRepTimer: TTimer;
    ReadMemBtn: TToolButton;
    AutoRepBtn: TToolButton;
    AutoRepTmEdit: TComboBox;
    Label5: TLabel;
    AdresBox: TComboBox;
    SizeBox: TComboBox;
    Label4: TLabel;
    Label2: TLabel;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ReadMemAct: TAction;
    AutoRepAct: TAction;
    SaveBufAct: TAction;
    WrMemAct: TAction;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    RdBackAct: TAction;
    RdNextAct: TAction;
    FillFFAct: TAction;
    FillZeroAct: TAction;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    SaveMemAct: TAction;
    LoadMemAct: TAction;
    ToolButton12: TToolButton;
    ToolButton14: TToolButton;
    SaveMemTxtAct: TAction;
    FillxxAct: TAction;
    WrMemBtn: TToolButton;
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
    procedure SaveBufActUpdate(Sender: TObject);
    procedure FillFFActUpdate(Sender: TObject);
  private
    MemType   : TBinaryMemType;
    function  ReadMem : TStatus;
    function  WriteMem : TStatus;
    function  GetPhAdr(Adr : cardinal):cardinal;
    function  ReadPtrValue(A : cardinal): cardinal;
    procedure GetFromText(var Adr : cardinal; var ShowAdr : cardinal; var Size : cardinal; var RegSize : cardinal);
  public
    procedure SaveToIni(Ini : TDotIniFile; SName : string); override;
    procedure LoadFromIni(Ini : TDotIniFile; SName : string); override;
    procedure SettingChg; override;
    function  GetDefaultCaption : string; override;
    procedure doParamsVisible(vis : boolean); override;
    procedure ShowMem(Adr : integer);
    procedure SetMemType(mtype : TBinaryMemType);
  end;

var
  BinaryMemForm: TBinaryMemForm;

implementation


{$R *.dfm}

Const
  smfH8_RESET  = 0;
  smfDSP_RESET = 6;
  BinaryMemName : array[TBinaryMemType] of string = ('BIN_INP','COILS');

function GetMemType(s : string): TBinaryMemType;
begin
  Result := bmCOILS;
  if s = BinaryMemName[bmBINARYINP] then
    Result := bmBINARYINP;
end;


procedure TBinaryMemForm.FormCreate(Sender: TObject);
begin
  inherited;
  MemFrame.MemSize := $100;
  MemFrame.RegisterSize := 1;
end;

procedure TBinaryMemForm.SetMemType(mtype : TBinaryMemType);
begin
  MemType := mtype;
  if MemType=bmBINARYINP then
    MemFrame.ByteGrid.Options := MemFrame.ByteGrid.Options - [goEditing];
  MemFrame.MemTypeName  := BinaryMemName[MemType];
  MemFrame.PaintActivPage;
  ShowCaption;
end;


type
  PByteAr = ^TByteAr;
  TByteAr = array[0..7] of byte;




function TBinaryMemForm.GetPhAdr(Adr : cardinal):cardinal;
begin
  Result := Adr;
end;

function  TBinaryMemForm.ReadPtrValue(A : cardinal): cardinal;
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


procedure TBinaryMemForm.GetFromText(var Adr : cardinal; var ShowAdr : cardinal; var Size : cardinal; var RegSize : cardinal);
var
  S   : cardinal;
  A   : cardinal;
begin
  A := MapParser.StrToAdr(AdresBox.Text);
  S := MapParser.StrToAdr(SizeBox.Text);
  RegSize := 1;
  Size := S;
  if A>0 then
  begin
    ShowAdr := A-1;
    Adr  := A-1;
  end
  else
    raise Exception.Create('Register adres = 0');  
end;

function TBinaryMemForm.ReadMem : TStatus;
var
  Adr     : cardinal;
  ShowAdr : cardinal;
  Size    : cardinal;
  RegSize : cardinal;
  TT      : cardinal;
begin
  inherited;
  GetFromText(Adr,ShowAdr,Size,RegSize);
  MemFrame.RegisterSize := RegSize;
  MemFrame.MemSize      := Size;
  MemFrame.SrcAdr       := ShowAdr;

  if Size<>0 then
  begin
    //MemFrame.ClrData;
    TT := GetTickCount;
    case MemType of
    bmBINARYINP:
       Result:=Dev.RdInpTable(Handle,MemFrame.MemBuf[0],Adr,Size);
    bmCOILS:
       Result:=Dev.RdOutTable(Handle,MemFrame.MemBuf[0],Adr,Size);
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



procedure TBinaryMemForm.ReadMemActUpdate(Sender: TObject);
begin
  (Sender  as TAction).Enabled := IsConnected and not(AutoRepAct.Checked);
end;

procedure TBinaryMemForm.SaveBufActUpdate(Sender: TObject);
begin
  inherited;
  (Sender  as TAction).Enabled := IsConnected and not(AutoRepAct.Checked) and (MemType = bmCOILS);
end;

procedure TBinaryMemForm.FillFFActUpdate(Sender: TObject);
begin
  inherited;
  (Sender  as TAction).Enabled := not(AutoRepAct.Checked) and (MemType = bmCOILS);
end;


procedure TBinaryMemForm.AutoReadActUpdate(Sender: TObject);
begin
 (Sender  as TAction).Enabled := IsConnected
end;


procedure TBinaryMemForm.ReadMemActExecute(Sender: TObject);
begin
  inherited;
  AddToList(AdresBox);
  AddToList(SizeBox);
  AddToList(AutoRepTmEdit);
  ReadMem;
end;


procedure TBinaryMemForm.RdBackActExecute(Sender: TObject);
var
  Adr     : cardinal;
  Size    : cardinal;
  RegSize : cardinal;
  ShowAdr : cardinal;
begin
  inherited;
  GetFromText(Adr,ShowAdr,Size,RegSize);
  Adr := ShowAdr-(Size div RegSize);
  AdresBox.Text := '0x'+IntToHex(Adr,8);
  ReadMem;
end;


procedure TBinaryMemForm.RdNextActExecute(Sender: TObject);
var
  Adr     : cardinal;
  Size    : cardinal;
  RegSize : cardinal;
  ShowAdr : cardinal;
begin
  inherited;
  GetFromText(Adr,ShowAdr,Size,RegSize);
  Adr := ShowAdr+(Size div RegSize);
  AdresBox.Text := '0x'+IntToHex(Adr,8);
  ReadMem;
end;

procedure TBinaryMemForm.WrMemActExecute(Sender: TObject);
begin
  inherited;
  WriteMem;
  MemFrame.SetNewData;
end;


procedure TBinaryMemForm.FillZeroActExecute(Sender: TObject);
begin
  inherited;
  MemFrame.FillZero;
end;

procedure TBinaryMemForm.FillFFActExecute(Sender: TObject);
begin
  inherited;
  MemFrame.FillOnes;
end;

function TBinaryMemForm.WriteMem : TStatus;
var
  i       : Cardinal;
  st      : TStatus;
  Adr     : cardinal;
  BufAdr  : cardinal;
begin
  BufAdr := MapParser.StrToAdr(AdresBox.Text);
  try
    i := 0;
    while i<MemFrame.MemSize do
    begin
      Adr := GetPhAdr(BufAdr)+i;
      st := Dev.WrOutput(Handle,Adr,MemFrame.MemBuf[i]);
      if st<>stOK then
        break;
      DoMsg(Format('WrOutput, Adr=%u',[Adr]));
      MemFrame.MemState[i] := csFull;
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


procedure TBinaryMemForm.SaveBufActExecute(Sender: TObject);
var
  i       : Cardinal;
  st      : TStatus;
  Adr     : cardinal;
  BufAdr  : cardinal;
  k       : integer;
begin
  BufAdr := MapParser.StrToAdr(AdresBox.Text);
  try
    i := 0;
    k := 0;
    while i<MemFrame.MemSize do
    begin
      if MemFrame.MemState[i]=csModify then
      begin
        Adr := GetPhAdr(BufAdr)+i;
        st := Dev.WrOutput(Handle,Adr,MemFrame.MemBuf[i]);
        if st<>stOK then
          break;
        DoMsg(Format('WrOutput, Adr=%u',[Adr]));
        MemFrame.MemState[i] := csFull;
        inc(k);
      end;
      inc(i);
    end;
    MemFrame.PaintActivPage;
    DoMsg(Format('WrOutput, k=%u  :%s',[k,Dev.GetErrStr(st)]));

  except
    on E: Exception do
    begin
      ShowMessage(E.Message);
    end;
  end;
end;

procedure TBinaryMemForm.ComboBoxExit(Sender: TObject);
begin
  inherited;
  AddToList(Sender as TComboBox);
end;

procedure TBinaryMemForm.AutoReadActExecute(Sender: TObject);
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

procedure TBinaryMemForm.AutoRepTimerTimer(Sender: TObject);
begin
  inherited;
  AutoRepTimer.Enabled:=false;
  if ReadMem=stOk then
    AutoRepTimer.Enabled:=True
  else
    AutoRepAct.Checked := false;
end;

procedure TBinaryMemForm.SaveToIni(Ini : TDotIniFile; SName : string);
begin
  inherited;
  Ini.WriteString(SName,'MemType',BinaryMemName[MemType]);
  Ini.WriteString(SName,'Adr',AdresBox.Text);
  Ini.WriteString(SName,'Adrs',AdresBox.Items.CommaText);
  Ini.WriteString(SName,'Size',SizeBox.Text);
  Ini.WriteString(SName,'Sizes',SizeBox.Items.CommaText);
  Ini.WriteString(SName,'RepTime',AutoRepTmEdit.Text);
  Ini.WriteString(SName,'RepTimes',AutoRepTmEdit.Items.CommaText);
  MemFrame.SaveToIni(Ini,SName);
end;

procedure TBinaryMemForm.LoadFromIni(Ini : TDotIniFile; SName : string);
begin
  inherited;
  SetMemType(GetMemType(Ini.ReadString(SName,'MemType',BinaryMemName[MemType])));
  AdresBox.Text        := Ini.ReadString(SName,'Adr','0');
  SizeBox.Text         := Ini.ReadString(SName,'Size','100');
  AdresBox.Items.CommaText:=Ini.ReadString(SName,'Adrs','0,4000,8000,800000');
  SizeBox.Items.CommaText :=Ini.ReadString(SName,'Sizes','100,200,400,1000');
  AutoRepTmEdit.Items.CommaText := Ini.ReadString(SName,'RepTimes','');
  MemFrame.LoadFromIni(Ini,SName);
  ShowCaption;

end;

procedure TBinaryMemForm.FormActivate(Sender: TObject);
begin
  inherited;
  ReloadMapParser;
end;



procedure TBinaryMemForm.SettingChg;
begin
  inherited;
end;


procedure TBinaryMemForm.ShowMem(Adr : integer);
begin
  AdresBox.Text := MapParser.IntToVarName(Adr);
  ReadMemAct.Execute;
  ShowParamAct.Execute;
end;


procedure TBinaryMemForm.AreaBoxChange(Sender: TObject);
begin
  inherited;
  MemFrame.Refresh;
end;

procedure TBinaryMemForm.MemFrameShowTypePageCtrlChange(Sender: TObject);
begin
  inherited;
  ShowCaption;
end;

procedure TBinaryMemForm.AdresBoxChange(Sender: TObject);
begin
  inherited;
  ShowCaption;
end;

function  TBinaryMemForm.GetDefaultCaption : string;
begin
  Result :=  BinaryMemName[MemType]+' : ' +AdresBox.Text;
end;

procedure TBinaryMemForm.doParamsVisible(vis : boolean);
begin
  inherited;
  MemFrame.doParamVisible(vis);
end;


procedure TBinaryMemForm.SaveMemActExecute(Sender: TObject);
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

procedure TBinaryMemForm.LoadMemActExecute(Sender: TObject);
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






procedure TBinaryMemForm.SaveMemTxtActExecute(Sender: TObject);
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
