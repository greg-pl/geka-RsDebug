program RsDebug;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  RsdDll in 'RsdDll.pas',
  RmtChildUnit in 'RmtChildUnit.pas' {ChildForm},
  GkStrUtils in 'GkStrUtils.pas',
  MapParserUnit in 'MapParserUnit.pas',
  ProgCfgUnit in 'ProgCfgUnit.pas',
  DevStrEditUnit in 'DevStrEditUnit.pas' {DevStrEditForm},
  SettingUnit in 'SettingUnit.pas' {SettingForm},
  VarListUnit in 'VarListUnit.pas' {VarListForm},
  TypeDefUnit in 'TypeDefUnit.pas',
  TypeDefEditUnit in 'TypeDefEditUnit.pas' {TypeDefEditForm},
  EditVarItemUnit in 'EditVarItemUnit.pas' {EditVarItemForm},
  StructShowUnit in 'StructShowUnit.pas' {StructShowForm},
  EditTypeItemUnit in 'EditTypeItemUnit.pas' {EditTypeItemForm},
  ToolsUnit in 'ToolsUnit.pas',
  UpLoadFileUnit in 'UpLoadFileUnit.pas' {UpLoadFileForm},
  UpLoadDefUnit in 'UpLoadDefUnit.pas',
  WavGenUnit in 'WavGenUnit.pas' {WavGenForm},
  ComTradeUnit in 'ComTradeUnit.pas',
  WrtControlUnit in 'WrtControlUnit.pas' {WrtControlForm},
  About in 'About.pas' {AboutForm},
  EditDrvParamsUnit in 'EditDrvParamsUnit.pas' {EditDrvParamsForm},
  TerminalUnit in 'TerminalUnit.pas' {TerminalForm},
  PictureView in 'PictureView.pas' {PictureViewForm},
  MemUnit in 'MemUnit.pas' {MemForm},
  RegMemUnit in 'RegMemUnit.pas' {RegMemForm: TMemForm},
  BinaryMemUnit in 'BinaryMemUnit.pas' {BinaryMemForm},
  MemFrameUnit in 'MemFrameUnit.pas' {MemFrame: TFrame},
  AnalogFrameUnit in 'AnalogFrameUnit.pas' {AnalogFrame: TFrame},
  BinaryFrameUnit in 'BinaryFrameUnit.pas' {BinaryFrame: TFrame},
  CommonDef in 'CommonDef.pas',
  Rz40EventsUnit in 'Rz40EventsUnit.pas' {Rz40EventsForm},
  CrcUnit in 'CrcUnit.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
