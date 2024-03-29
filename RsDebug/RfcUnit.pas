unit RfcUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, RmtChildUnit, ImgList, ActnList, ExtCtrls, StdCtrls, ComCtrls,
  ToolWin, Grids, Clipbrd,
  RsdDll,
  ProgCfgUnit,
  MapParserUnit, Menus;


const
  PREFIX = 'RFC_WRAPPER_';
  RFC_INSTANCE = 'Rfc_Instance';
  MAX_FUNCTION_PARAMETERS = 16;
  MAX_FUNCTION_MEMORY_BUFFER_SIZE = 32768;

  Rfc_StatusReady = 0;
  Rfc_StatusExecute = 1;
  Rfc_StatusPreEntry = 2;
  Rfc_StatusEntered = 3;
  Rfc_StatusErrorNotAligned = 4;
  Rfc_StatusErrorNotWrapper = 5;

type
  TFunctionParametersTab = array [0..MAX_FUNCTION_PARAMETERS-1] of  cardinal;
  Rfc_ControlBlock_t = record
    FunctionAddress : cardinal;
    FunctionStatus : cardinal;
    Id : cardinal;
    FunctionReturn : cardinal;
    FunctionParameters : TFunctionParametersTab;
    //FunctionMemoryBuffer: array [0..MAX_FUNCTION_MEMORY_BUFFER_SIZE-1] of  cardinal;
  end;


  TRfcForm = class(TChildForm)
    FunctionSelectBox: TComboBox;
    Label1: TLabel;
    IdEdit: TLabeledEdit;
    ParameterList: TStringGrid;
    ToolButton1: TToolButton;
    RunFunctionAct: TAction;
    ReadResultAct: TAction;
    ShowBufferAct: TAction;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    FunctionStatusEdit: TLabeledEdit;
    FunctionReturnEdit: TLabeledEdit;
    SelectFunPopupMenu: TPopupMenu;
    Copyfullname1: TMenuItem;
    procedure FunctionSelectBoxDropDown(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure RunFunctionActExecute(Sender: TObject);
    procedure ReadResultActExecute(Sender: TObject);
    procedure ShowBufferActExecute(Sender: TObject);
    procedure RunFunctionActUpdate(Sender: TObject);
    procedure Copyfullname1Click(Sender: TObject);
  private
    AdrCpx      : TAdrCpx;
    RfcInstanceAdr : integer;
    function LoadParamsTab(var tab : TFunctionParametersTab; var errText : string): boolean;

  public
    procedure SaveToIni(Ini : TDotIniFile; SName : string); override;
    procedure LoadFromIni(Ini : TDotIniFile; SName : string); override;
    procedure ReloadMapParser; override;
    function  GetDefaultCaption : string; override;
  end;



implementation

uses IniFiles;

{$R *.dfm}

function getFunctionstatusText(v : integer): string;
begin
  case v of
  Rfc_StatusReady           : result := 'Ready';
  Rfc_StatusExecute         : result := 'Execute';
  Rfc_StatusPreEntry        : result := 'Entry';
  Rfc_StatusEntered         : result := 'Entered';
  Rfc_StatusErrorNotAligned : result := 'ErrorNotAligned';
  Rfc_StatusErrorNotWrapper : result := 'ErrorNotWrapper';
  else
    result := Format('Unknow status, code=%u',[v]);
  end;


end;

procedure TRfcForm.FormShow(Sender: TObject);
var
  i : integer;
begin
  inherited;
  ParameterList.Rows[0].CommaText := 'lp. "Parametr name" "Parametr value" Chg';
  for i:=0 to MAX_FUNCTION_PARAMETERS-1 do
  begin
    ParameterList.Cells[0,i+1] := IntToStr(i+1);
  end;
  ReloadMapParser;
end;

function  TRfcForm.GetDefaultCaption : string;
begin
  Result :=  'RFC: ' +FunctionSelectBox.Text;
end;

procedure TRfcForm.ReloadMapParser;
begin
  RfcInstanceAdr := MapParser.GetVarAdress(RFC_INSTANCE);
  if RfcInstanceAdr = UNKNOWN_ADRESS then
    StatusBar.Panels[2].Text := 'Unknow RfcInstance address'
  else
    StatusBar.Panels[2].Text := Format('RfcInstance: 0x%08x',[RfcInstanceAdr]);
end;

procedure TRfcForm.SaveToIni(Ini : TDotIniFile; SName : string);
var
  i : integer;
begin
  inherited;
  Ini.WriteString(SName,'RfcFunc',FunctionSelectBox.Text);
  Ini.WriteString(SName,'ID',IdEdit.Text);
  for i:=0 to MAX_FUNCTION_PARAMETERS-1 do
  begin
    Ini.WriteString(SName,'ParamName_'+IntToStr(i),ParameterList.Cells[1,i+1]);
    Ini.WriteString(SName,'ParamVal_'+IntToStr(i),ParameterList.Cells[2,i+1]);
  end;
end;

procedure TRfcForm.LoadFromIni(Ini : TDotIniFile; SName : string);
var
  i : integer;
  s : string;
  idx : integer;
begin
  inherited;
  MapParser.MapItemList.LoadToList(PREFIX,FunctionSelectBox.Items);
  s := Ini.ReadString(SName,'RfcFunc',FunctionSelectBox.Text);
  idx := FunctionSelectBox.Items.IndexOf(s);
  if idx>=0 then
     FunctionSelectBox.ItemIndex := idx;
  IdEdit.Text := Ini.ReadString(SName,'ID',IdEdit.Text);
  for i:=0 to MAX_FUNCTION_PARAMETERS-1 do
  begin
    ParameterList.Cells[1,i+1] := Ini.ReadString(SName,'ParamName_'+IntToStr(i),ParameterList.Cells[1,i+1]);
    ParameterList.Cells[2,i+1] := Ini.ReadString(SName,'ParamVal_'+IntToStr(i),ParameterList.Cells[2,i+1]);
  end;
end;


procedure TRfcForm.FunctionSelectBoxDropDown(Sender: TObject);
begin
  inherited;
  MapParser.MapItemList.LoadToList(PREFIX,FunctionSelectBox.Items);

end;

function TRfcForm.LoadParamsTab(var tab : TFunctionParametersTab; var errText : string): boolean;
label
  ErrorLab;
var
  i : integer;
  s : string;
begin
  Result := true;
  for i:=0 to MAX_FUNCTION_PARAMETERS-1 do
    tab[i]:=0;
  for i:=0 to MAX_FUNCTION_PARAMETERS-1 do
  begin
    s := ParameterList.Cells[2,i+1];
    if s<>'' then
    begin
      tab[i] := MapParser.StrToAdr(s);
      if tab[i] = UNKNOWN_ADRESS then
      begin
        errText := Format('Unknow parametr %u',[i+1]);
        Result := false;
        goto ErrorLab;
      end;
    end;
  end;
ErrorLab:

end;


procedure TRfcForm.RunFunctionActExecute(Sender: TObject);
label
  ErrorLab;
var
  Rfc: Rfc_ControlBlock_t;
  errTxt : string;
  st : TStatus;
begin
  inherited;
  errTxt := '';
  Rfc.FunctionAddress :=  MapParser.GetVarAdress(PREFIX+FunctionSelectBox.Text);
  if Rfc.FunctionAddress=UNKNOWN_ADRESS then
  begin
    errTxt := 'Unknow Rfc function';
    goto ErrorLab;
  end;
  Rfc.Id := MapParser.StrToAdr(IdEdit.Text);
  if Rfc.Id=UNKNOWN_ADRESS then
  begin
    errTxt := 'Unknow Id';
    goto ErrorLab;
  end;

  if not LoadParamsTab(Rfc.FunctionParameters, errTxt) then
    goto ErrorLab;

  Rfc.FunctionStatus := Rfc_StatusExecute;
  Rfc.FunctionReturn := 0;

  st := Dev.WriteMem(Handle,Rfc,RfcInstanceAdr,sizeof(Rfc));
  DoMsg(Dev.GetErrStr(st));
ErrorLab:
  if errTxt <> '' then
    Application.MessageBox(pchar(errTxt),'Error', mb_OK);
end;

procedure TRfcForm.ReadResultActExecute(Sender: TObject);
label
  ErrorLab;
var
  Rfc: Rfc_ControlBlock_t;
  st : TStatus;
  errTxt : string;
begin
  inherited;
  errTxt := '';
  st := Dev.ReadMem(Handle,Rfc,RfcInstanceAdr,sizeof(Rfc));
  if st<>stOK then
    DoMsg(Dev.GetErrStr(st));

  FunctionStatusEdit.Text := getFunctionstatusText(Rfc.FunctionStatus);
  FunctionReturnEdit.Text := Format('%u',[Rfc.FunctionReturn]);

ErrorLab:
  if errTxt <> '' then
    Application.MessageBox(pchar(errTxt),'Error', mb_OK);
end;

procedure TRfcForm.ShowBufferActExecute(Sender: TObject);
begin
  inherited;
  AdrCpx.AreaName := '';
  AdrCpx.Caption := 'Rfc Buffer';
  AdrCpx.Adres := RfcInstanceAdr + sizeof(Rfc_ControlBlock_t);
  AdrCpx.Size := MAX_FUNCTION_MEMORY_BUFFER_SIZE;
  PostMessage(Application.MainForm.Handle,wm_ShowmemWin,integer(@AdrCpx),0);

end;

procedure TRfcForm.RunFunctionActUpdate(Sender: TObject);
var
  q : boolean;
begin
  inherited;
  q := false;
  if Dev<>nil then
    q :=  Dev.Connected and (RfcInstanceAdr <> UNKNOWN_ADRESS);
  (sender as TAction).Enabled := q;
end;

procedure TRfcForm.Copyfullname1Click(Sender: TObject);
begin
  inherited;
  clipboard.SetTextBuf(pchar(PREFIX+FunctionSelectBox.Text));
end;

end.
