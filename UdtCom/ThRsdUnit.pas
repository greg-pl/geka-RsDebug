unit ThRsdUnit;

interface

uses
  Windows, Messages, SysUtils, Classes,
  GlobalMan;


const
  CommLibGuid     : TGUID ='{FAE45317-98B4-4F99-8682-2C822CDC5196}';
{
  LibPropertyStr : string =
    '<?xml version="1.0" standalone="yes"?>'+
    '<LIB_DESCR>'+
      '<INFO TYPE="RS" DESCR="��cze RS (protok� Modbus+)" SIGN="MCOM"/>'+
      '<PARAMS>'+
        '<PARAM DESCR="Nr portu" TYPE="COM_NR" DEFAULT="1" />'+
        '<PARAM DESCR="Nr urz�dzenia" TYPE="BYTE" DEFAULT="255"/>'+
        '<PARAM DESCR="Szybko�� transmisji" TYPE="RS_SPEED" DEFAULT="19200"/>'+
        '<PARAM DESCR="RTU/ASCII" TYPE="SELECT" DEFAULT="19200"/>'+
      '</PARAMS>'+
    '</LIB_DESCR>';

  LibPropertyStrV2 : string =
    '<?xml version="1.0" standalone="yes"?>'+
    '<CMM_DESCR>'+
      '<CMM_INFO TYPE="RS" DESCR="��cze RS (protok� Modbus+)" SIGN="MCOM"/>'+
      '<GROUP>'+
        '<ITEM NAME="COM" TYPE="COM_NR" DESCR="Nr portu" DEFVALUE="1" />'+
        '<ITEM NAME="DEV_NR" TYPE="INT" DESCR="Nr urz�dzenia" DEFVALUE="1" MIN="1" MAX="240" />'+
        '<ITEM NAME="RS_SPEED" TYPE="SELECT" DESCR="Szybko�� transmisji" DEFVALUE="19200" '+
            'ITEMS="115200|57600|56000|38400|19200|14400|9600|4800|2400|1200|600|300|110"/>'+
        '<ITEM NAME="MODE" DESCR="Tryb pracy RTU/ASCII" TYPE="SELECT" ITEMS="RTU|ASCII" DEFVALUE="RTU"/>'+
        '<ITEM NAME="PARITY" DESCR="Bit parzysto�ci" TYPE="SELECT" ITEMS="N|E|O" ITEMDESCR="Brak|Parzysty|Nie parzysty"  DEFVALUE="N"/>'+
      '</GROUP>'+
    '</CMM_DESCR>';
}
  LibPropertyStr : string =
    '<?xml version="1.0" standalone="yes"?>'+
    '<LIB_DESCR>'+
      '<INFO TYPE="RS" DESCR="Port RS (protocol Modbus+)" SIGN="MCOM"/>'+
      '<PARAMS>'+
        '<PARAM DESCR="Port number" TYPE="COM_NR" DEFAULT="1" />'+
        '<PARAM DESCR="Device number" TYPE="BYTE" DEFAULT="255"/>'+
        '<PARAM DESCR="Baudrate" TYPE="RS_SPEED" DEFAULT="19200"/>'+
        '<PARAM DESCR="RTU/ASCII" TYPE="SELECT" DEFAULT="19200"/>'+
      '</PARAMS>'+
    '</LIB_DESCR>';

  LibPropertyStrV2 : string =
    '<?xml version="1.0" standalone="yes"?>'+
    '<CMM_DESCR>'+
      '<CMM_INFO TYPE="RS" DESCR="Port RS (protocol Modbus+)" SIGN="MCOM"/>'+
      '<GROUP>'+
        '<ITEM NAME="COM" TYPE="COM_NR" DESCR="Port number" DEFVALUE="1" />'+
        '<ITEM NAME="DEV_NR" TYPE="INT" DESCR="Device number" DEFVALUE="1" MIN="1" MAX="240" />'+
        '<ITEM NAME="RS_SPEED" TYPE="SELECT" DESCR="Baudrate" DEFVALUE="19200" '+
            'ITEMS="115200|57600|56000|38400|19200|14400|9600|4800|2400|1200|600|300|110"/>'+
        '<ITEM NAME="MODE" DESCR="Mode RTU/ASCII" TYPE="SELECT" ITEMS="RTU|ASCII" DEFVALUE="RTU"/>'+
        '<ITEM NAME="PARITY" DESCR="Parity" TYPE="SELECT" ITEMS="N|E|O" ITEMDESCR="No parity|Even|Odd"  DEFVALUE="N"/>'+
      '</GROUP>'+
    '</CMM_DESCR>';

  evProgress  = 0;
  evFlow      = 1;
  evWorkOnOff = 4;


  stBadId         = 10;
  stTimeErr       = 11;
  stNotOpen       = 12;
  stSetupErr      = 14;
  stUserBreak     = 15;
  stNoSemafor     = 16;
  stBadRepl       = 17;
  stBadArguments  = 18;
  stMdbError      = 32;
  stBufferToSmall = 50;  // publiczny - rozpoznawany przez warstw� wy�sza
  stMdbExError    = 100;


type
  TStatus   = integer;
  TAccId    = integer;
  TSesID    = cardinal;
  TFileNr   = byte;
  TSeGuid   = record
                d1 : cardinal;
                d2 : cardinal;
              end;


  TCallBackFunc = procedure(Id :TAccId; CmmId : integer; Ev : integer; R : real); stdcall;

procedure LibIdentify(var LibGuid :TGUID); stdcall;
procedure SetEmulateVer(Ver : integer); stdcall;
function  GetLibProperty:pchar; stdcall;
function  RegisterCallBackFun(Id :TAccId; CmmId : integer; CallBackFunc : TCallBackFunc): TStatus; stdcall;
function  GetPortHandle(Id :TAccId): THandle;  stdcall;
function  SetBreakFlag(Id :TAccId; Val:boolean): TStatus; stdcall;
function  GetDrvParamList(ToSet : boolean): pchar; stdcall;
function  GetDrvStatus(Id :TAccId; ParamName : pchar; ParamValue :pchar; MaxRpl:integer): TStatus; stdcall;
function  SetDrvParam(Id :TAccId; ParamName : pchar; ParamValue :pchar): TStatus; stdcall;
function  GetErrStr(Id :TAccId; Code :TStatus; S : pChar; Max: integer): boolean;  stdcall;

//  ConnectStr:
//  MCOM;nr_rs;nr_dev;rs_speed;[ASCII|RTU];[N|E|O]
//  MCOM;1;7;115200;RTU;N
function  AddDev(ConnectStr : pchar): TAccId; stdcall;
function  DelDev(Id :TAccId):TStatus; stdcall;
function  OpenDev(Id :TAccId):TStatus; stdcall;
procedure CloseDev(Id :TAccId); stdcall;
function  GetDevNr(Id :TAccId):byte; stdcall;

// funkcje podstawowe Modbusa
function  RdOutTable(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
function  RdInpTable(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
function  RdReg(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
function  RdAnalogInp(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
function  WrOutput(Id :TAccId; Adress : word; Val : word):TStatus; stdcall;
function  WrReg(Id :TAccId; Adress : word; Val : word):TStatus; stdcall;
function  WrMultiReg(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;

// odczyt, zapis pami�ci
function  ReadS(Id :TAccId; var S; var Vec : Cardinal): TStatus; stdcall;
function  ReadMem(Id :TAccId; var Buffer; adr : Cardinal; size : Cardinal): TStatus; stdcall;
function  WriteMem(Id :TAccId; var Buffer; adr : Cardinal; Size : Cardinal): TStatus; stdcall;
function  WriteCtrl(Id :TAccId; nr: byte; b: byte): TStatus; stdcall;
function  ReadCtrl(Id :TAccId; nr : byte; var b : byte): TStatus; stdcall;

//obsluga terminala
function  TerminalSendKey(Id :TAccId; key : char):TStatus; stdcall;
function  TerminalRead(Id :TAccId; buf : pchar; var rdcnt : integer):TStatus; stdcall;


// dostep do sesji i plik�w

function  SeOpenSesion(Id :TAccId; var SesId : TSesID) : TStatus; stdcall;
function  SeCloseSesion(Id :TAccId; SesId : TSesID) : TStatus; stdcall;
function  SeOpenFile(Id :TAccId; SesId : TSesID; FName : pchar; Mode : byte; var FileNr : TFileNr):TStatus; stdcall;
function  SeGetDir(Id :TAccId; SesId : TSesID; FName : pchar; Attrib : byte; Buffer : pchar; MaxLen : integer):TStatus; stdcall;
function  SeGetDrvList(Id :TAccId; SesId : TSesID; DrvList : pchar):TStatus; stdcall;
function  SeShell(Id :TAccId; SesId : TSesID; Command : pchar; ResultStr : pchar; MaxLen : integer):TStatus; stdcall;
function  SeGetGuidEx(Id :TAccId; SesId : TSesID; FileName : pchar; var Guid : TSeGuid):TStatus; stdcall;
function  SeReadFileEx(Id :TAccId; SesId : TSesID; FileName : pchar; autoclose: boolean; var buf;
              var size: integer; var FileNr: TFileNr):TStatus; stdcall;
function  SeReadFile(Id :TAccId; SesId : TSesID;  FileNr : TFileNr; var buf; var Cnt : integer):TStatus; stdcall;
function  SeWriteFile(Id :TAccId;  SesId : TSesID; FileNr : TFileNr; const buf; var Cnt : integer):TStatus; stdcall;
function  SeSeek(Id :TAccId;  SesId : TSesID; FileNr : TFileNr; Offset  : integer; Orgin : byte; var Pos : integer):TStatus; stdcall;
function  SeGetFileSize(Id :TAccId;  SesId : TSesID; FileNr : TFileNr; var FileSize : integer):TStatus; stdcall;
function  SeCloseFile(Id :TAccId; SesId : TSesID;  FileNr : TFileNr):TStatus; stdcall;
function  SeGetGuid(Id :TAccId; SesId : TSesID;  FileNr : TFileNr; var Guid : TSeGuid):TStatus; stdcall;



Exports
    LibIdentify,
    SetEmulateVer,
    GetLibProperty,
    RegisterCallBackFun,
    GetPortHandle,
    SetBreakFlag,
    GetDrvStatus,
    SetDrvParam,
    GetDrvParamList,

    AddDev,
    DelDev,
    OpenDev,
    CloseDev,
    GetDevNr,

    RdOutTable,
    RdInpTable,
    RdReg,
    RdAnalogInp,
    WrOutput,
    WrReg,
    WrMultiReg,

    ReadS,
    ReadMem,
    WriteMem,
    WriteCtrl,
    ReadCtrl,
    GetErrStr,
    GetDrvParamList,
    GetDrvStatus,
    SetDrvParam,

    TerminalSendKey,
    TerminalRead,

    SeOpenSesion,
    SeCloseSesion,
    SeOpenFile,
    SeGetDir,
    SeGetDrvList,
    SeShell,
    SeReadFile,
    SeWriteFile,
    SeSeek,
    SeGetFileSize,
    SeCloseFile,
    SeGetGuid,
    SeGetGuidEx,
    SeReadFileEx;



implementation

uses Math;

const
  MAX_MDB_FRAME_SIZE = 240;
  MAX_MDB_STD_FRAME_SIZE = 112;

type
  TComPort   = integer;
  TBaudRate = (br110, br300, br600, br1200, br2400, br4800, br9600,
               br14400, br19200, br38400, br56000, br57600, br115200);
  TDriverMode = (dmSTD,dmSLOW,dmFAST);

  PByteAr   = ^TByteAr;
  TByteAr   = array[0..MAX_MDB_FRAME_SIZE-1+40] of byte;
  TTabBit   = array[0..32768] of boolean;
  TTabByte  = array[0..32768] of byte;
  TTabWord  = array[0..32768] of word;

  TMdbMode = (mdbRTU,mdbASCII);
  TParity  = (paNONE,paEVEN,paODD);


  TDevItem = class (TObject)
  private
    AccID         : integer;
    ComNr         : integer;
    FDevNr        : integer;
    BaudRate      : TBaudrate;
    FMdbMode      : TMdbMode;
    FParity       : TParity;
    FCallBackFunc : TCallBackFunc;
    FCmmId        : integer;

    FBreakFlag    : boolean;

    ComHandle     : THandle;
    SemHandle     : THandle;
    ErrStr        : Shortstring;

    LastFinished  : Cardinal;
    FrameCnt      : integer;
    FrameRepCnt   : integer;
    WaitCnt       : integer;  // licznik wymuszonych przerw
    SumRecTime    : integer;
    SumSendTime   : integer;

    FCountDivide  : integer;
    FMdbStdCndDiv : integer;      // podzia� na kr�tsze ramki dla standardowych zapyta� MODBUS
    FAskNumber    : word;
    glProgress    : boolean;       // false -> progress wysy�a procedura Konwers
    DriverMode    : TDriverMode;
    Rs485Wait     : boolean;
    FClr_ToRdCnt  : boolean;       // odbi�r ramki az do przerwy

    function  GetNewAskNr : word;

    procedure FSetCountDivide(AValue : integer);
    procedure FSetMdbStdCndDiv(AValue : integer);
    function  GetComAcces: boolean;
    procedure ReleaseComAcces;

    function  RsWrite(var Buffer; Count: Integer): Integer;
    function  RsRead(var Buffer; Count: Integer): Integer;
    procedure PurgeInOut;
    function  Konwers(RepZad: integer; var Buf; Count : byte; var OutBuf; var RecLen : integer): TStatus; overload;
    function  Konwers(var Buf; Count : byte; var OutBuf; var RecLen : integer): TStatus; overload;
    function  Konwers(var Buf; Count : byte; var OutBuf): TStatus; overload;
    function  Konwers(var Buf; Count : byte; var RecLen : integer): TStatus; overload;

    //function  ProceddCRC(CRC : word; Data : byte):word;
    function  ProceddCRC_1(CRC : word; Data : byte):word;
    function  CheckCRC(const p; count:word):boolean;
    function  MakeCRC(const p; count:word):word;
    function  ReciveRTUAnswer(var Buffer; ToReadCnt : integer; var RecLen: integer) : boolean;
    function  ReciveASCIIAnswer(var Buffer; ToReadCnt : integer; var RecLen: integer) : boolean;
    function  RdRegHd(var QA : TByteAr; Adress : word; Count :word):TStatus;
    function  RdAbnalogInpHd(var QA : TByteAr; Adress : word; Count :word):TStatus;
    function  WrMultiRegHd(Adress : word; Count :word; pW: pWord):Tstatus;
    function  DSwap(w :Cardinal):Cardinal;
    //function  GetSmallInt(const b):Smallint;
    procedure SetSmallInt(const b; Val :Smallint);
    function  GetLongInt(const b):cardinal;
    procedure SetLongInt(const b; Val :cardinal);
    function  GetDWord(const b):cardinal;
    //procedure SetDWord(const b; Val :cardinal);
    function  SeGetDirHd(First : boolean; SesId : TSesID; FName : pchar; Attrib : byte;
       Buffer : pchar; MaxLen : integer; var Len : integer):TStatus;
    function  SeReadFileHd(SesId : TSesID;  FileNr : TFileNr; var buf; var Cnt : integer):TStatus;
    function  SeWriteFileHd(SesId : TSesID; FileNr : TFileNr; const buf; var Cnt : integer):TStatus;
  protected
    procedure  GoBackFunct(Ev: integer; R: real);
    procedure  SetProgress(F: real); overload;
    procedure  SetProgress(Cnt,Max:integer); overload;
    procedure  MsgFlowSize(R: real);
    procedure  SetWorkFlag(w : boolean);

    function  RsReadByte(var b : byte):boolean;
    function  InQue: Integer;
    function  OutQue: Integer;
    procedure RsWriteByte(b : byte);
    procedure RsWriteWord(b : Word);
  public
    MaxTime   : integer;
    constructor Create(AId : TAccId; AComNr : TComPort; ADevNr: integer;ABaudRate :TBaudrate;
                            AMode : TMdbMode; AParity : TParity);
    destructor  Destroy; override;
    property    CountDivide: integer  read FCountDivide  write FSetCountDivide;
    property    MdbStdCndDiv: integer read FMdbStdCndDiv write FSetMdbStdCndDiv;

    function    ValidHandle : boolean;
    function    SetupState: TStatus;
    function    Open : TStatus;
    procedure   Close;
    procedure   BreakPulse;
    property    DevNr  : integer read FDevNr;
    function    SetBreakFlag(Val: boolean) : TStatus;
    function    GetDrvStatus(ParamName : pchar; ParamValue :pchar; MaxRpl:integer): TStatus;
    function    SetDrvParam(ParamName : pchar; ParamValue :pchar): TStatus;

    procedure   RegisterCallBackFun(ACallBackFunc : TCallBackFunc; CmmId : integer);
    // funkcje podstawowe Modbusa
    function    RdOutTable(var Buf; Adress : word; Count :word):TStatus;
    function    RdInpTable(var Buf; Adress : word; Count :word):TStatus;
    function    RdReg(var Buf; Adress : word; Count :word):TStatus;
    function    RdAnalogInp(var Buf; Adress : word; Count :word):TStatus;
    function    WrOutput(Adress : word; Val : boolean):TStatus;
    function    RdStatus(var Val : byte):TStatus;
    function    WrReg(Adress : word; Val : word):TStatus;
    function    WrMultiReg(var Buf; Adress : word; Count :word):TStatus;
    // odczyt, zapis pami�ci
    function    RdMemory(var Buf; Adress : cardinal; Count :cardinal):TStatus;
    function    WrMemory(const Buf; Adress : cardinal; Count :cardinal):TStatus;
    function    RdDevInfo(DevName : pchar; var TabVec: cardinal): TStatus;
    function    RdCtrlByte(Nr: byte; var Val : byte):TStatus;
    function    WrCtrlByte(Nr: byte; Val : byte):TStatus;

    //obsluga terminala
    function    TerminalSendKey(key : char):TStatus;
    function    TerminalRead(buf : pchar; var rdcnt : integer):TStatus;

    // dostep do sesji i plik�w
    function  GetErrStr(Code :TStatus; Buffer : pchar; MaxLen : integer):boolean;
    function  SeOpenSesion(var SesId : TSesID) : TStatus;
    function  SeCloseSesion(SesId : TSesID) : TStatus;
    function  SeOpenFile(SesId : TSesID; FName : pchar; Mode : byte; var FileNr : TFileNr):TStatus;
    function  SeGetDir(SesId : TSesID; FName : pchar; Attrib : byte; Buffer : pchar; MaxLen : integer):TStatus;


    function  SeGetDrvList(SesId : TSesID; DrvList : pchar):TStatus;
    function  SeShell(SesId : TSesID; Command : pchar; ResultStr : pchar; MaxLen : integer):TStatus;
    function  SeGetGuidEx(SesId : TSesID; FileName : pchar; var Guid : TSeGuid):TStatus;
    function  SeReadFileEx(SesId : TSesID; FileName : pchar; autoclose: boolean; var buf;
              var size: integer; var FileNr: TFileNr):TStatus;
    function  SeReadFile(SesId : TSesID;  FileNr : TFileNr; var buf; var Cnt : integer):TStatus;
    function  SeWriteFile(SesId : TSesID; FileNr : TFileNr; const buf; var Cnt : integer):TStatus;
    function  SeSeek(SesId : TSesID; FileNr : TFileNr; Offset  : integer; Orgin : byte; var Pos : integer):TStatus;
    function  SeGetFileSize(SesId : TSesID; FileNr : TFileNr; var FileSize : integer):TStatus;
    function  SeCloseFile(SesId : TSesID;  FileNr : TFileNr):TStatus;
    function  SeGetGuid(SesId : TSesID;  FileNr : TFileNr; var Guid : TSeGuid):TStatus;
  end;


  TDevAcces = class(TList)
  private
    FCurrId          : TAccId;
    FCriSection      : TRTLCriticalSection;
    function GetBoudRate(BdTxt: shortstring; var Baund :TBaudRate) : boolean;
    function GetMdbMode(BdTxt: shortstring; var MdbMode:TMdbMode) : boolean;
    function GetParity(BdTxt: shortstring; var Parity:TParity) : boolean;
    function GetTocken(s : pChar; var p: integer):shortstring;
    function GetId:TAccId;
  public
    constructor Create;
    destructor  Destroy; override;
    function AddAcc(ConnectStr : pchar): TAccId;
    function DelAcc(AccId : TAccId):TStatus;
    function FindId(AccId : TAccId):TDevItem;
  end;



var
  GlobDevAcces : TDevAcces;
  EmulateVer   : integer;

function lolo(w : Cardinal):byte;
begin
  lolo := w and $ff;
end;
function lohi(w : Cardinal):byte;
begin
  lohi := (w shr 8) and $ff;
end;
function hilo(w : Cardinal):byte;
begin
  hilo := (w shr 16) and $ff;
end;

const
  dcb_Binary           = $00000001;
  dcb_Parity           = $00000002;
  dcb_OutxCtsFlow      = $00000004;
  dcb_OutxDsrFlow      = $00000008;
  dcb_DtrControl       = $00000030;
  dcb_DsrSensivity     = $00000040;
  dcb_TXContinueOnXOff = $00000080;
  dcb_OutX             = $00000100;
  dcb_InX              = $00000200;
  dcb_ErrorChar        = $00000400;
  dcb_Null             = $00000800;
  dcb_RtsControl       = $00003000;
  dcb_AbortOnError     = $00004000;

function LastErr: shortstring;
begin
  Result := IntToStr(GetLastError);
end;

//---------------------  TDevItem ---------------------------
constructor TDevItem.Create(AId : TAccId; AComNr : TComPort; ADevNr: integer;ABaudRate :TBaudrate;
                            AMode : TMdbMode; AParity : TParity);
begin
  inherited Create;
  AccID        := AId;
  ComNr        := AComNr;
  FDevNr       := ADevNr;
  BaudRate     := ABaudrate;
  FMdbMode     := AMode;
  FParity      := AParity;
  DriverMode   := dmFAST; //;
  Rs485Wait    := false;
  FClr_ToRdCnt := false;

  LastFinished := GetTickCount;
  MaxTime      := 5000;
  CountDivide  := 128;
  MdbStdCndDiv := MAX_MDB_STD_FRAME_SIZE;
end;

destructor TDevItem.Destroy;
begin
  inherited Destroy;
end;

function TDevItem.ValidHandle : boolean;
begin
  Result := (ComHandle<>INVALID_HANDLE_VALUE);
end;

const
  TabCharSize : array[TBaudRate] of real = (
    10*(1000/110),      // br110
    10*(1000/300),      // br300
    10*(1000/600),      // br600
    10*(1000/1200),     // br1200
    10*(1000/2400),     // br2400
    10*(1000/4800),     // br4800
    10*(1000/9600),     // br9600
    10*(1000/14400),    // br14400
    10*(1000/19200),    // br19200
    10*(1000/38400),    // br38400
    10*(1000/56000),    // br56000
    10*(1000/57600),    // br57600
    10*(1000/115200));  // br115200



function TDevItem.SetupState: TStatus;
var
  DCB       : TDCB;
  Timeouts  : TCommTimeouts;
  RMode     : TFPURoundingMode;
  t         : cardinal;
  ErrCode   : integer;
  s         : string;
begin
  FillChar(DCB, SizeOf(DCB), 0);
  DCB.DCBlength := SizeOf(DCB);
  DCB.Flags    := DCB.Flags or dcb_Binary;
  if FParity<>paNONE then
  begin
    DCB.Flags    := DCB.Flags or dcb_Parity;
    if FParity=paEVEN then
      DCB.Parity   := EVENPARITY;
    if FParity=paODD then
      DCB.Parity   := ODDPARITY;
  end
  else
    DCB.Parity   := NOPARITY;
  DCB.StopBits := ONESTOPBIT;
  case BaudRate of
    br110:    DCB.BaudRate := CBR_110;
    br300:    DCB.BaudRate := CBR_300;
    br600:    DCB.BaudRate := CBR_600;
    br1200:   DCB.BaudRate := CBR_1200;
    br2400:   DCB.BaudRate := CBR_2400;
    br4800:   DCB.BaudRate := CBR_4800;
    br9600:   DCB.BaudRate := CBR_9600;
    br14400:  DCB.BaudRate := CBR_14400;
    br19200:  DCB.BaudRate := CBR_19200;
    br38400:  DCB.BaudRate := CBR_38400;
    br56000:  DCB.BaudRate := CBR_56000;
    br57600:  DCB.BaudRate := CBR_57600;
    br115200: DCB.BaudRate := CBR_115200;
  end;
  case FMdbMode of
  mdbRTU   : DCB.ByteSize := 8;
  mdbASCII : DCB.ByteSize := 7;
  end;
  DCB.XonLim := 2048;
  DCB.XoffLim := 1024;
  DCB.XonChar := #17;
  DCB.XoffChar := #19;


  Result := stSetupErr;
  if not SetCommState(ComHandle, DCB) then
  begin
    ErrCode := GetLastError;
    s := SysErrorMessage(ErrCode);
    Exit;
  end;
  if not GetCommTimeouts(ComHandle, Timeouts) then    Exit;

  if DriverMode = dmSTD then
  begin
    RMode := GetRoundMode;
    SetRoundMode(rmUp);
    Timeouts.ReadIntervalTimeout := round(10*TabCharSize[BaudRate]);
    t := round(4*TabCharSize[BaudRate]);
    if t<5 then t:=5;
    Timeouts.ReadTotalTimeoutMultiplier := t;

    Timeouts.ReadIntervalTimeout := 30;
    Timeouts.ReadTotalTimeoutMultiplier := 1; //todo
    Timeouts.ReadTotalTimeoutConstant := 100;
    SetRoundMode(RMode);
  end
  else
  begin
    Timeouts.ReadIntervalTimeout := MAXDWORD;
    Timeouts.ReadTotalTimeoutMultiplier := 0;
    Timeouts.ReadTotalTimeoutConstant := 0;
  end;

  Timeouts.WriteTotalTimeoutMultiplier := 0;
  Timeouts.WriteTotalTimeoutConstant := 0;
  if not SetCommTimeouts(ComHandle, Timeouts) then    Exit;
  if not SetupComm(ComHandle, $400, $400) then        Exit;
  Result := stOk;
end;


function  TDevItem.Open : TStatus;
begin
  Result := GetCommHandle(ComNr,ComHandle,SemHandle);
  if Result=stOk then
  begin
    if GetComAcces then
    begin
      Result := SetupState;
      ReleaseComAcces;
    end
    else
      Result := stNoSemafor;
  end;
  FrameRepCnt := 0;
  FrameCnt    := 0;
  WaitCnt     := 0;
  SumRecTime  := 0;
  SumSendTime := 0;
end;

procedure TDevItem.Close;
begin
  CloseCommHandle(ComNr);
  ComHandle:=INVALID_HANDLE_VALUE;
  SemHandle:=INVALID_HANDLE_VALUE;
end;

function TDevItem.DSwap(w :Cardinal):Cardinal;
begin
  Result := ((w and $000000ff) shl 24) or ((w and $0000ff00) shl 8) or
            ((w and $00ff0000) shr 8)  or ((w and $ff000000) shr 24);
end;

{
function  TDevItem.GetSmallInt(const b):Smallint;
var
  p : pByte;
begin
  p := @b;
  Result := p^;
  inc(p);
  Result := smallint((Result shl 8) or p^);
end;
}

procedure TDevItem.SetSmallInt(const b; Val :Smallint);
var
  p : pByte;
begin
  p := @b;
  p^ := byte(Val shr 8);
  inc(p);
  p^ := byte(Val);
end;

function  TDevItem.GetLongInt(const b):cardinal;
var
  p : pByte;
begin
  p := @b;
  Result := p^;
  inc(p);
  Result := (Result shl 8) or p^;
  inc(p);
  Result := (Result shl 8) or p^;
  inc(p);
  Result := LongInt((Result shl 8) or p^);
end;
procedure TDevItem.SetLongInt(const b; Val :cardinal);
var
  p : pByte;
begin
  p := @b;
  p^ := byte(Val shr 24);
  inc(p);
  p^ := byte(Val shr 16);
  inc(p);
  p^ := byte(Val shr 8);
  inc(p);
  p^ := byte(Val);
end;

function  TDevItem.GetDWord(const b):cardinal;
var
  p : pByte;
begin
  p := @b;
  Result := p^;
  inc(p);
  Result := (Result shl 8) or p^;
  inc(p);
  Result := (Result shl 8) or p^;
  inc(p);
  Result := (Result shl 8) or p^;
end;

{
procedure TDevItem.SetDWord(const b; Val :cardinal);
var
  p : pByte;
begin
  p := @b;
  p^ := byte(Val shr 24);
  inc(p);
  p^ := byte(Val shr 16);
  inc(p);
  p^ := byte(Val shr 8);
  inc(p);
  p^ := byte(Val);
end;
}

//  -------------------- Obsluga RS  -----------------------------------------

function TDevItem.GetComAcces: boolean;
begin
  Result := (WaitForSingleObject(SemHandle,MaxTime)=WAIT_OBJECT_0);
end;

procedure TDevItem.ReleaseComAcces;
var
  LCnt : Cardinal;
begin
  ReleaseSemaphore(SemHandle,1,@LCnt);
end;

function TDevItem.InQue: Integer;
var
  Errors: Cardinal;
  ComStat: TComStat;
begin
  ClearCommError(ComHandle, Errors, @ComStat);
  Result := ComStat.cbInQue;
end;

function TDevItem.OutQue: Integer;
var
  Errors: Cardinal;
  ComStat: TComStat;
begin
  ClearCommError(ComHandle, Errors, @ComStat);
  Result := ComStat.cbOutQue;
end;

function TDevItem.RsWrite(var Buffer; Count: Integer): Integer;
var
  Overlapped   : TOverlapped;
  BytesWritten : Cardinal;
  q            : boolean;
  TT           : Cardinal;
begin
  TT := GetTickCount;
  FillChar(Overlapped, SizeOf(Overlapped), 0);
  Overlapped.hEvent := CreateEvent(nil, True, True, nil);
  WriteFile(ComHandle, Buffer, Count, BytesWritten, @Overlapped);

  WaitForSingleObject(Overlapped.hEvent, INFINITE);
  q := GetOverlappedResult(ComHandle, Overlapped, BytesWritten, False);
  CloseHandle(Overlapped.hEvent);
  Result := BytesWritten;
  if not(q) then Result := 0;
  TT := Cardinal(GetTickCount-TT);
  inc(SumSendTime,TT);
end;


procedure TDevItem.RsWriteByte(b : byte);
begin
  RsWrite(b,1);
end;

procedure TDevItem.RsWriteWord(b : Word);
begin
  RsWrite(b,2);
end;

var
  TTTT : cardinal;
  TTTT2 : cardinal;
function TDevItem.RsRead(var Buffer; Count: Integer): Integer;
var
  Overlapped : TOverlapped;
  BytesRead  : Cardinal;
  q          : boolean;
begin
  TTTT := GetTickCount;
  FillChar(Overlapped, SizeOf(Overlapped), 0);
  Overlapped.hEvent := CreateEvent(nil, True, True, nil);
  ReadFile(ComHandle, Buffer, Count, BytesRead, @Overlapped);
  TTTT2 := GetTickCount;
  WaitForSingleObject(Overlapped.hEvent, 1000);
  TTTT2 := GetTickCount-TTTT2;
  q:=GetOverlappedResult(ComHandle, Overlapped, BytesRead, False);
  CloseHandle(Overlapped.hEvent);
  Result := BytesRead;
  if not(q) then
    Result := 0;
  TTTT := GetTickCount-TTTT;
end;



function  TDevItem.RsReadByte(var b : byte):boolean;
begin
  Result:=(RsRead(b,1)=1);
end;


procedure TDevItem.PurgeInOut;
begin
  PurgeComm(ComHandle, PURGE_RXABORT or PURGE_RXCLEAR or PURGE_TXABORT or PURGE_TXCLEAR);
end;

procedure  TDevItem.GoBackFunct(Ev: integer; R: real);
begin
  if Assigned(FCallBackFunc) then
    FCallBackFunc(AccID,FCmmId,Ev,R);
end;

procedure TDevItem.SetProgress(F: real);
begin
  GoBackFunct(evProgress,F);
end;

procedure  TDevItem.SetProgress(Cnt,Max:integer);
Var
  R : real;
begin
  if Max<>0 then
    R := 100*(Cnt/max)
  else
    R:=100;
  SetProgress(R);
end;

procedure TDevItem.MsgFlowSize(R: real);
begin
  GoBackFunct(evFlow,R);
end;

procedure TDevItem.SetWorkFlag(w : boolean);
begin
  if w then
    GoBackFunct(evWorkOnOff,1)
  else
    GoBackFunct(evWorkOnOff,0);
end;


procedure TDevItem.FSetCountDivide(AValue : integer);
begin
  if AValue>MAX_MDB_FRAME_SIZE then AValue:= MAX_MDB_FRAME_SIZE;
  FCountDivide := AValue;
end;

procedure TDevItem.FSetMdbStdCndDiv(AValue : integer);
begin
  if AValue>MAX_MDB_STD_FRAME_SIZE then AValue:= MAX_MDB_STD_FRAME_SIZE;
  FMdbStdCndDiv := AValue;
end;

//-----------------------------------------------------------------------------
//--------   OBSLUGA PROTOKOLU    ---------------------------------------------
//-----------------------------------------------------------------------------
const CrcTab : array[0..255] of word =
                       (  $0000, $C0C1, $C181, $0140, $C301, $03C0, $0280, $C241,
                          $C601, $06C0, $0780, $C741, $0500, $C5C1, $C481, $0440,
                          $CC01, $0CC0, $0D80, $CD41, $0F00, $CFC1, $CE81, $0E40,
                          $0A00, $CAC1, $CB81, $0B40, $C901, $09C0, $0880, $C841,
                          $D801, $18C0, $1980, $D941, $1B00, $DBC1, $DA81, $1A40,
                          $1E00, $DEC1, $DF81, $1F40, $DD01, $1DC0, $1C80, $DC41,
                          $1400, $D4C1, $D581, $1540, $D701, $17C0, $1680, $D641,
                          $D201, $12C0, $1380, $D341, $1100, $D1C1, $D081, $1040,
                          $F001, $30C0, $3180, $F141, $3300, $F3C1, $F281, $3240,
                          $3600, $F6C1, $F781, $3740, $F501, $35C0, $3480, $F441,
                          $3C00, $FCC1, $FD81, $3D40, $FF01, $3FC0, $3E80, $FE41,
                          $FA01, $3AC0, $3B80, $FB41, $3900, $F9C1, $F881, $3840,
                          $2800, $E8C1, $E981, $2940, $EB01, $2BC0, $2A80, $EA41,
                          $EE01, $2EC0, $2F80, $EF41, $2D00, $EDC1, $EC81, $2C40,
                          $E401, $24C0, $2580, $E541, $2700, $E7C1, $E681, $2640,
                          $2200, $E2C1, $E381, $2340, $E101, $21C0, $2080, $E041,
                          $A001, $60C0, $6180, $A141, $6300, $A3C1, $A281, $6240,
                          $6600, $A6C1, $A781, $6740, $A501, $65C0, $6480, $A441,
                          $6C00, $ACC1, $AD81, $6D40, $AF01, $6FC0, $6E80, $AE41,
                          $AA01, $6AC0, $6B80, $AB41, $6900, $A9C1, $A881, $6840,
                          $7800, $B8C1, $B981, $7940, $BB01, $7BC0, $7A80, $BA41,
                          $BE01, $7EC0, $7F80, $BF41, $7D00, $BDC1, $BC81, $7C40,
                          $B401, $74C0, $7580, $B541, $7700, $B7C1, $B681, $7640,
                          $7200, $B2C1, $B381, $7340, $B101, $71C0, $7080, $B041,
                          $5000, $90C1, $9181, $5140, $9301, $53C0, $5280, $9241,
                          $9601, $56C0, $5780, $9741, $5500, $95C1, $9481, $5440,
                          $9C01, $5CC0, $5D80, $9D41, $5F00, $9FC1, $9E81, $5E40,
                          $5A00, $9AC1, $9B81, $5B40, $9901, $59C0, $5880, $9841,
                          $8801, $48C0, $4980, $8941, $4B00, $8BC1, $8A81, $4A40,
                          $4E00, $8EC1, $8F81, $4F40, $8D01, $4DC0, $4C80, $8C41,
                          $4400, $84C1, $8581, $4540, $8701, $47C0, $4680, $8641,
                          $8201, $42C0, $4380, $8341, $4100, $81C1, $8081, $4040 );

function  TDevItem.ProceddCRC_1(CRC : word; Data : byte):word;
begin
  Result := CrcTab[(Crc xor Data) and $FF] xor (Crc shr 8);
end;

{
function  TDevItem.ProceddCRC(CRC : word; Data : byte):word;
const
  Gen_poly:word= $A001;
var
  i    : byte;
begin
  Crc:=Crc xor Data;
  for i:=1 to 8 do
  begin
    if Crc mod 2=1 then
      Crc:=((Crc div 2) xor Gen_Poly)
    else
      crc:=crc div 2;
  end;
  Result:= Crc;
end;
}

function TDevItem.MakeCRC(const p; count:word):word;
const
  Gen_poly:word= $A001;
var
  a    : word;
  CRC  : word;
  n    : word;
begin
   Crc:=$FFFF;
   for n:=0 to Count-1 do
   begin
     a := TByteAr(p)[n];
     Crc := ProceddCRC_1(Crc,a);
   end;
   Result:= Crc;
end;

function TDevItem.CheckCRC(const p; count:word):boolean;
begin
  Result := (MakeCrc(p,Count)=0);
end;

function TDevItem.ReciveRTUAnswer(var Buffer; ToReadCnt : integer; var RecLen: integer) : boolean;
{
  function ShiftToBuf(var Buffer; RecLen:integer; var SrcBuf; L:integer): integer;
  var
    p : pByte;
  begin
    if L<>0 then
    begin
      p := pByte(@Buffer);
      inc(p,RecLen);
      move(SrcBuf,p^,L);
      inc(RecLen,L);
    end;
    Result := RecLen;
  end;
}
const
  TIME_TO_RPL = 200;
var
  TT : cardinal;
  T2 : cardinal;
  Q  : TByteAr;
  dT : cardinal;
  L  : integer;
  TimeFlag : boolean;
begin
  if FClr_ToRdCnt then
    ToReadCnt:=0;
  T2 := GetTickCount;
  if DriverMode=dmSTD then
  begin
    if (ToReadCnt=0) or (ToReadCnt>sizeof(TByteAr)) then
       RecLen := RsRead(Buffer,sizeof(TByteAr))
    else
    begin
       RecLen := RsRead(Buffer,ToReadCnt);
    end;
  end
  else
  begin
    dT := round(5*TabCharSize[BaudRate]);
    if dt<10 then dt:=10;

    TT := GetTickCount;
    RecLen:=0;
    while RecLen=0 do
    begin
      L := RsRead(Q[RecLen],sizeof(Q)-RecLen);
      inc(RecLen,L);
      if (DriverMode=dmSLOW) and (L=0) then
        Sleep(dT);
      if GetTickCount-TT>TIME_TO_RPL then
      begin
        break;
      end;
    end;

    TT := GetTickCount;
    TimeFlag:=false;
    while true do
    begin
      if RecLen=sizeof(Q) then
        break;
      try
        L := RsRead(Q[RecLen],sizeof(Q)-RecLen);
      except
        L:=0;
      end;
      inc(RecLen,L);
      if L<>0 then
      begin
        TT:=GetTickCount;
        TimeFlag:=false;
      end;
      if (ToReadCnt<>0) and  (ToReadCnt=RecLen) then
      begin
        break;
      end;
      if GetTickCount-TT>dT then
      begin
        if TimeFlag then
        begin
          break;
        end
        else
        begin
          Sleep(dT);
        end;
        TimeFlag:=true;
      end;
      if (DriverMode=dmSLOW) and (L=0) then
        Sleep(dT);
    end;
    T2 := GetTickCount-T2;
    inc(SumRecTime,T2);
    move(Q,Buffer,RecLen);
  end;

  if (ToReadCnt=0) or (ToReadCnt=RecLen) then
  begin
    if RecLen>0 then
      Result:= CheckCrc(Buffer,RecLen)
    else
      Result:=false;
  end
  else
    Result:=false;
end;


function  TDevItem.ReciveASCIIAnswer(var Buffer; ToReadCnt : integer; var RecLen: integer) : boolean;
  function HexVal(ch : char): byte;
  begin
         if (ch>='0') and (ch<='9') then result := ord(ch)-ord('0')
    else if (ch>='A') and (ch<='F') then result := ord(ch)-ord('A')+10
    else if (ch>='a') and (ch<='f') then result := ord(ch)-ord('a')+10
    else result := 0;
  end;

var
  RecBuf : array of char;
  N      : integer;
  Len    :  Cardinal;
  i      : integer;
  a      : byte;
  sum    : byte;
begin
  Result := false;
  N :=  sizeof(TByteAr)*2+3;
  SetLength(RecBuf,N);
  Len := RsRead(RecBuf[0],N);
  if (Len>3) and
     (RecBuf[0]=':') and
     (RecBuf[len-1]=#10) and
     (RecBuf[len-2]=#13) then
  begin
    N := (Len-3) div 2;
    sum := 0;
    for i:=0 to N-1 do
    begin
      a :=16*HexVal(RecBuf[2*i+1])+HexVal(RecBuf[2*i+2]);
      TByteAr(Buffer)[i]:=a;
      sum := byte(sum+a);
    end;
    if sum=0 then
      Result := true;
    RecLen := N;
  end
  else
    RecLen := 0;
  SetLength(RecBuf,0);
end;

function TDevItem.Konwers(var Buf; Count : byte; var OutBuf; var RecLen : integer): TStatus;
begin
  Result := Konwers(5,Buf,Count,OutBuf,RecLen);
end;

function  TDevItem.Konwers(RepZad: integer; var Buf; Count : byte; var OutBuf; var RecLen : integer): TStatus;

  procedure WriteToFile(const Buf; Len: integer);
  var
    Str : TMemoryStream;
  begin
    Str := TMemoryStream.Create;
    try
      Str.Write(Buf,Len);
      Str.SaveToFile('Buffer.bin');
    finally
      Str.Free;
    end;
  end;

  procedure BildAsciiBuf(var BufToSnd; const B; Count:integer);
    procedure PlaceChar(var p : pchar; b: char);
    begin
      p^:=b;
      inc(p);
    end;
    procedure PlaceByte(var p : pchar; b: byte);
    const
      HexCyfr : array[0..15] of char='0123456789ABCDEF';
    begin
      PlaceChar(p,HexCyfr[(b shr 4) and $0f]);
      PlaceChar(p,HexCyfr[b and $0f])
    end;

  var
    P : pchar;
    i : integer;
    a : byte;
    sum : byte;
  begin
    p := pchar(@BufToSnd);
    PlaceChar(p,':');
    sum:=0;
    for i:=0 to Count-1 do
    begin
      a:=ord(pchar(@B)[i]);
      sum := byte(sum+a);
      PlaceByte(p,a);
    end;
    sum := $100-sum;
    PlaceByte(p,sum);
    PlaceChar(p,#$0D);
    PlaceChar(p,#$0A);
  end;

var
  w      : word;
  Rep    : byte;
  q      : boolean;
  MyBuf     : array of byte;
  CntToSnd  : integer;
  Cmd       : byte;
  CmdRep    : byte;
  ToReadCnt : integer;
begin
  ToReadCnt := RecLen;
  if not(ValidHandle) then
  begin
    ErrStr:='Nie otwarty port.';
    Result := stNotOpen;
    Exit;
  end;
  if GetComAcces then
  begin
    if not(glProgress) then
    begin
      SetProgress(0);
      MsgFlowSize(0);
      SetWorkFlag(true);
    end;

    case FMdbMode of
    mdbRTU   :
      begin
        CntToSnd := Count+2;
        setlength(MyBuf,CntToSnd);
        move(Buf,MyBuf[0],Count);
        w:=MakeCrc(MyBuf[0],Count);
        MyBuf[Count] := lo(w);
        MyBuf[Count+1] := hi(w);
      end;
    mdbASCII :
      begin
        CntToSnd := 1+2*(Count+1)+2;
        setlength(MyBuf,CntToSnd);
        BildAsciiBuf(MyBuf[0],Buf,Count);
      end;
    else
      CntToSnd := 0;
    end;

    if TByteAr(Buf)[0]<>0 then
    begin
      Rep:=RepZad;
      repeat
        q := true;
        CmdRep := 0;
        if not(FBreakFlag) then
        begin
          PurgeInOut;
          inc(FrameCnt);
          if Rs485Wait then
          begin
            while GetTickCount-LastFinished<2 do
            begin
              sleep(1);
              inc(WaitCnt);
            end;
          end;
          RsWrite(MyBuf[0],CntToSnd);

          case FMdbMode of
          mdbRTU:
            q := ReciveRTUAnswer(OutBuf,ToReadCnt,RecLen);
          mdbASCII:
            q := ReciveASCIIAnswer(OutBuf,ToReadCnt,RecLen);
          else
            q := false;
          end;

          Cmd := TByteAr(Buf)[1];
          CmdRep := TByteAr(OutBuf)[1];
          if (TByteAr(OutBuf)[0]<>FDevNr) or (Cmd <> (CmdRep and $7F)) then
          begin
            q := false;   // odebrano nie t� ramk�
          end;

          if not(q) then
          begin
            inc(FrameRepCnt);
            dec(rep);
            if (rep<>0) then
            begin
              sleep(10)
            end;
          end;
          LastFinished := GetTickCount;
        end;
      until (rep=0) or q or FBreakFlag;

      Result := stOk;
      if FBreakFlag then
      begin
        Result := stUserBreak;
      end
      else if rep=0 then
      begin
        Result := stBadRepl;
      end
      else if not(q) then
      begin
        Result := stTimeErr;
      end
      else
      begin
        if (CmdRep and $80)<>0 then
        begin
          if TByteAr(OutBuf)[2]<>4 then
            Result := stMdbError+TByteAr(OutBuf)[2]
          else
            Result := stMdbExError+TByteAr(OutBuf)[3]
        end;
      end;
      if not(glProgress) then
      begin
        SetProgress(100);
        SetWorkFlag(false);
      end;
    end
    else
    begin    // Brodcast
      PurgeInOut;
      RsWrite(Buf,Count+2);
      Result := stOk;
    end;
    SetLength(MyBuf,0);
    ReleaseComAcces;
  end
  else
    Result := stNoSemafor;
end;

function  TDevItem.Konwers(var Buf; Count : byte; var RecLen : integer): TStatus;
var
  OutBuf : TByteAr;
begin
  Result := Konwers(Buf,Count,OutBuf,RecLen);
end;

function  TDevItem.Konwers(var Buf; Count : byte; var OutBuf): TStatus;
var
  RecLen : integer;
begin
  RecLen:=0;
  Result := Konwers(Buf,Count,OutBuf,RecLen);
end;


procedure  TDevItem.BreakPulse;
begin
  if ValidHandle then
  begin
    if GetComAcces then
    begin
      SetCommBreak(ComHandle);
      Sleep(10);
      ClearCommBreak(ComHandle);
      ReleaseComAcces;
    end;
  end;
end;

function  TDevItem.SetBreakFlag(Val: boolean) : TStatus;
begin
  FBreakFlag := Val;
  Result := stOK;
end;

function TDevItem.GetDrvStatus(ParamName : pchar; ParamValue :pchar; MaxRpl:integer): TStatus;
var
  s : string;
begin
  s := '';
       if ParamName='REPEAT_CNT'  then s := IntToStr(FrameRepCnt)
  else if ParamName='FRAME_CNT'   then s := IntToStr(FrameCnt)
  else if ParamName='WAIT_CNT'    then s := IntToStr(WaitCnt)
  else if ParamName='RECIVE_TIME' then s := IntToStr(SumRecTime)
  else if ParamName='SEND_TIME'   then s := IntToStr(SumSendTime)
  else if ParamName='DIVIDE_LEN'  then s := IntToStr(CountDivide)
  else if ParamName='DRIVER_MODE' then s := IntToStr(ord(DriverMode))
  else if ParamName='RS485_WAIT'  then s := IntToStr(byte(Rs485Wait))
  else if ParamName='CLR_RDCNT'   then s := IntToStr(byte(FClr_ToRdCnt));

  if s<>'' then
  begin
    StrPLCopy(ParamValue,s,MaxRpl);
    Result := stOK;
  end
  else
    Result := stBadArguments;
end;

function  TDevItem.SetDrvParam(ParamName : pchar; ParamValue :pchar): TStatus;
var
  n : integer;
begin
  Result := stOk;
  if ParamName='DIVIDE_LEN' then
  begin
    CountDivide := StrToIntDef(ParamValue,MAX_MDB_FRAME_SIZE);
  end
  else if ParamName='DRIVER_MODE' then
  begin
    n := StrToIntDef(ParamValue,ord(dmSTD));
    if (n>=ord(low(TDriverMode))) and (n<=ord(high(TDriverMode))) then
    begin
      DriverMode := TDriverMode(n);
      SetupState;
    end;
  end
  else if ParamName='RS485_WAIT' then
  begin
    n := StrToIntDef(ParamValue,1);
    Rs485Wait := (n<>0);
  end
  else if ParamName='CLR_RDCNT' then
  begin
    n := StrToIntDef(ParamValue,1);
    FClr_ToRdCnt := (n<>0);
  end
  else
    Result := stBadArguments;
end;

const
  ToSetParamStr : string = 'DIVIDE_LEN;DRIVER_MODE;RS485_WAIT;CLR_RDCNT;';
  ToGetParamStr : string = 'REPEAT_CNT;FRAME_CNT;WAIT_CNT;RECIVE_TIME;SEND_TIME;DIVIDE_LEN;DRIVER_MODE;RS485_WAIT;CLR_RDCNT;';



function  GetDrvParamList(ToSet : boolean): pchar; stdcall;
begin
  if ToSet then
    Result := pchar(ToSetParamStr)
  else
    Result := pchar(ToGetParamStr)
end;



procedure TDevItem.RegisterCallBackFun(ACallBackFunc : TCallBackFunc; CmmId : integer);
begin
  FCallBackFunc := ACallBackFunc;
  FCmmId        := CmmId;
end;


//-----------------------------------------------------


function TDevItem.RdOutTable(var Buf; Adress : word; Count :word):TStatus;
var
  Q      : TByteAr;
  QA     : TByteAr;
  i      : word;
  b,mask : byte;
begin
  Q[0]:=FDevNr;
  Q[1]:=$01;
  SetSmallInt(Q[2],SmallInt(Adress));
  SetSmallInt(Q[4],SmallInt(Count));
  Result:=Konwers(Q,6,QA);
  if Result=stOk then
  begin
    if (QA[0]=FDevNr) and (QA[1]=1) then
    begin
      for i:=0 to Count-1 do
      begin
        b := QA[3+(i div 8)];
        mask := $01 shl (i mod 8);
        TTabBit(Buf)[i]:= ((b and mask)<>0);
      end;
    end
    else
      Result := stBadRepl;
  end;
end;

function TDevItem.RdInpTable(var Buf; Adress : word; Count :word):TStatus;
var
  Q      : TByteAr;
  QA     : TByteAr;
  i      : word;
  b,mask : byte;
begin
  Q[0]:=FDevNr;
  Q[1]:=$02;
  SetSmallInt(Q[2],SmallInt(Adress));
  SetSmallInt(Q[4],SmallInt(Count));
  Result:=Konwers(Q,6,QA);
  if Result=stOk then
  begin
    if (QA[0]=FDevNr) and (QA[1]=2) then
    begin
      for i:=0 to Count-1 do
      begin
        b := QA[3+(i div 8)];
        mask := $01 shl (i mod 8);
        TTabBit(Buf)[i]:= ((b and mask)<>0);
      end;
    end
    else
      Result := stBadRepl;
  end;
end;

function TDevItem.RdRegHd(var QA : TByteAr; Adress : word; Count :word):TStatus;
var
  Q :  TByteAr;
begin
  if Adress>0 then
  begin
    Dec(Adress);
    Q[0]:=FDevNr;
    Q[1]:=$03;
    SetSmallInt(Q[2],SmallInt(Adress));
    SetSmallInt(Q[4],SmallInt(Count));
    Result:=Konwers(Q,6,QA);
    if Result=stOk then
    begin
      if not((QA[0]=FDevNr) and (QA[1]=$03)) then
        Result := stBadRepl;
    end;
  end  
  else
    Result := stBadArguments;
end;

function TDevItem.RdReg(var Buf; Adress : word; Count :word):TStatus;
var
  Cnt    : word;
  QA     : TByteAr;
  i      : word;
  w      : word;
  st     : TStatus;
  N      : integer;
  SCnt   : integer;
  Count1 : integer;
begin
  glProgress := true;
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);

  N := 0;
  st := stOk;
  Count1 := Count;
  SCnt := 0;
  while (Count<>0) and (st=stOk) do
  begin
    Cnt:=Count;
    if Cnt>FMdbStdCndDiv then
      Cnt := FMdbStdCndDiv;
    st := RdRegHd(QA,Adress,Cnt);
    if st=stOk then
    begin
      for i:=0 to Cnt-1 do
      begin
         w := QA[2*i+3]*256+QA[2*i+4];
         TTabWord(Buf)[N]:=w;
         inc(N);
      end;
    end;

    Adress := word(Adress+Cnt);
    Count := Count-Cnt;
    SCnt := SCnt + Cnt;

    SetProgress(SCnt,Count1);
    MsgFlowSize(SCnt);
  end;

  SetProgress(100);
  MsgFlowSize(Count);
  SetWorkFlag(false);
  glProgress := false;
  Result := st;
end;

function TDevItem.RdAbnalogInpHd(var QA : TByteAr; Adress : word; Count :word):TStatus;
var
  Q      : TByteAr;
  RecLen : integer;
begin
  if Adress>0 then
  begin
    Dec(Adress);
    Q[0]:=FDevNr;
    Q[1]:=$04;
    SetSmallInt(Q[2],SmallInt(Adress));
    SetSmallInt(Q[4],SmallInt(Count));
    RecLen:=0;
    Result:=Konwers(Q,6,QA,RecLen);
    if Result=stOk then
    begin
      if not((QA[0]=FDevNr) and (QA[1]=$04) and (QA[2]=Count*2) and (RecLen=3+2*Count+2)) then
        Result := stBadRepl;
    end;
  end
  else
    Result := stBadArguments;
end;


function TDevItem.RdAnalogInp(var Buf; Adress : word; Count :word):TStatus;
var
  Cnt: word;
  QA : TByteAr;
  i  : word;
  w  : word;
  st : TStatus;
  N  : integer;
  SCnt   : integer;
  Count1 : integer;
begin
  try
    glProgress := true;
    SetProgress(0);
    MsgFlowSize(0);
    SetWorkFlag(true);

    N := 0;
    st := stOk;
    Count1 := Count;
    SCnt := 0;
    while (Count<>0) and (st=stOk) do
    begin
      Cnt:=Count;
      if Cnt>FMdbStdCndDiv then
        Cnt := FMdbStdCndDiv;
      st := RdAbnalogInpHd(QA,Adress,Cnt);
      if st=stOk then
      begin
        for i:=0 to Cnt-1 do
        begin
           w := QA[2*i+3]*256+QA[2*i+4];
           TTabWord(Buf)[N]:=w;
           inc(N);
        end;
      end;

      Adress := word(Adress+Cnt);
      Count := Count-Cnt;
      SCnt := SCnt + Cnt;

      SetProgress(SCnt,Count1);
      MsgFlowSize(SCnt);
    end;
    SetProgress(100);
    MsgFlowSize(Count);
    SetWorkFlag(false);
  except
    st := stDelphiError;
  end;
  Result := st;
end;

function TDevItem.WrOutput(Adress : word; Val : boolean):Tstatus;
var
  Q      : TByteAr;
  QA     : TByteAr;
  i      : byte;
  RecLen : integer;
begin
  Dec(Adress);
  Q[0]:=FDevNr;
  Q[1]:=$05;
  SetSmallInt(Q[2],SmallInt(Adress));
  if Val then  Q[4]:=$FF
         else  Q[4]:=$00;
  Q[5]:=$00;
  RecLen:=8;
  Result:=Konwers(Q,6,QA,RecLen);
  if Result=stOk then
  begin
    if FDevNr<>0 then
    begin
      for i:=0 to 5 do
        if q[i]<>qa[i] then
          Result := stBadRepl;
    end;
  end;
end;

function TDevItem.WrReg(Adress : word; Val : word):TStatus;
var
  Q  :  TByteAr;
  QA : TByteAr;
  i  : integer;
begin
  Dec(Adress);
  Q[0]:=FDevNr;
  Q[1]:=$06;
  SetSmallInt(Q[2],SmallInt(Adress));
  SetSmallInt(Q[4],SmallInt(Val));
  Result:=Konwers(Q,6,QA);
  if Result=stOk then
  begin
    if FDevNr<>0 then
    begin
      for i:=0 to 5 do
        if q[i]<>qa[i] then
          Result := stBadRepl;
    end;
  end;
end;

function TDevItem.RdStatus(var Val : byte):TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
begin
  Q[0]:=FDevNr;
  Q[1]:=$07;
  Result:=Konwers(Q,2,QA);
  if Result=stOk then
    if not((qa[0]=FDevNr) and (qa[1]=7)) then
      Result := stBadRepl;
  if Result=stOk then
    Val := qa[2];
end;

function TDevItem.WrMultiRegHd(Adress : word; Count :word; pW: pWord):Tstatus;
var
  Q    :  TByteAr;
  QA   :  TByteAr;
  w    :  word;
  i    : integer;
  rCnt : word;
  rAdr : word;
begin
  Dec(Adress);
  Q[0]:=FDevNr;
  Q[1]:=16;
  SetSmallInt(Q[2],SmallInt(Adress));
  SetSmallInt(Q[4],SmallInt(Count));
  Q[6]:= 2*Count;
  for i:=0 to Count-1 do
  begin
    w := pw^;
    inc(pw);
    Q[7+i*2+0]:= byte(w shr 8);
    Q[7+i*2+1]:= byte(w);
  end;
  Result:=Konwers(Q,7+2*Count,QA);
  if Result=stOK then
  begin
    rAdr := QA[2]*256+QA[3];
    rCnt := QA[4]*256+QA[5];
    if FDevNr<>0 then
    begin
      if not((QA[0]=FDevNr) and (QA[1]=16) and (rCnt=Count) and (rAdr=Adress)) then
        Result := stBadRepl;
    end;
  end;
end;

function TDevItem.WrMultiReg(var Buf; Adress : word; Count :word):TStatus;
var
  Cnt  : word;
  st   : TStatus;
  pw   : pWord;
  SCnt : integer;
begin
  glProgress := true;
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);

  st := stOk;
  pw := pWord(@Buf);
  SCnt:=0;
  while (Count<>0) and (st=stOk) do
  begin
    Cnt:=Count;
    if Cnt>FMdbStdCndDiv then
      Cnt := FMdbStdCndDiv;
    st := WrMultiRegHd(Adress,Cnt,pw);
    inc(pw,Cnt);
    Adress := word(Adress +Cnt);
    dec(Count,Cnt);
    inc(SCnt,Cnt);
    SetProgress(SCnt,Count);
    MsgFlowSize(SCnt);
  end;

  SetProgress(100);
  MsgFlowSize(Count);
  SetWorkFlag(false);
  glProgress := false;

  Result := st;
end;

{$Q-}

function TDevItem.RdMemory(var Buf; Adress : cardinal; Count :cardinal):TStatus;

  function RdMemoryHd(FDevNr : byte; Adress : cardinal; Count :byte; var QA : TByteAr):Tstatus;
  var
    Q :  TByteAr;
    RecLen : integer;
  begin
    Q[0]:=FDevNr;
    Q[1]:=41;
    Q[2]:=Count;
    Q[3]:=0;
    SetLongInt(Q[4],Adress);
    RecLen:=Count+10;
    Result:=Konwers(Q,8,QA,RecLen);
    if Result=stOk then
      if not((QA[0]=FDevNr) and (QA[1]=41)) then
        Result := stBadRepl;
  end;

var
  Cnt: integer;
  QA : TByteAr;
  i  : word;
  st : Tstatus;
  p  : pByte;
  SCnt : cardinal;
begin
  glProgress := true;
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);

  st := stOk;
  p := pByte(@Buf);
  SCnt := 0;
  while (SCnt<>Count) and (st=stOk) do
  begin
    Cnt:=Count-SCnt;
    if Cnt>FCountDivide then
      Cnt := FCountDivide;
    st := RdMemoryHd(FDevNr,Adress,Cnt,QA);
    if st=stOk then
    begin
      for i:=0 to Cnt-1 do
      begin
        p^:=qa[i+8];
        inc(p);
      end;
    end;
    inc(Adress,Cnt);
    inc(SCnt,Cnt);
    SetProgress(SCnt,Count);
    MsgFlowSize(SCnt);
    SetWorkFlag(true);
  end;
  Result := st;
  SetProgress(100);
  MsgFlowSize(Count);
  SetWorkFlag(false);
  glProgress := false;
end;
{$Q+}

{$Q-}
function TDevItem.WrMemory(const Buf; Adress : cardinal; Count :cardinal):TStatus;

  function WrMemoryHd(FDevNr : byte; Adress : cardinal; Count :byte; p : pByte):TStatus;
  var
    Q  : TByteAr;
    QA : TByteAr;
    RecLen : integer;
  begin
    Q[0]:=FDevNr;
    Q[1]:=42;
    Q[2]:=Count;
    Q[3]:=0;
    SetLongInt(Q[4],Adress);
    move(p^,q[8],Count);
    RecLen:=10;
    Result:=Konwers(Q,8+Count,QA,RecLen);
    if Result=stOk then
      if not((QA[0]=FDevNr) and (QA[1]=42)) then
        Result := stBadRepl;
  end;

var
  Cnt  : integer;
  st   : TStatus;
  p    : pByte;
  SCnt : cardinal;
begin
  glProgress := true;
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);

  st := stOk;
  p := pByte(@Buf);
  SCnt := 0;
  while (Count<>SCnt) and (st=stOk) do
  begin
    Cnt:=Count-SCnt;
    if Cnt>FCountDivide then
      Cnt := FCountDivide;
    st := WrMemoryHd(FDevNr,Adress,Cnt,p);
    inc(p,Cnt);
    inc(Adress,Cnt);
    inc(SCnt,Cnt);
    SetProgress(SCnt,Count);
    MsgFlowSize(SCnt);
  end;
  Result := st;
  SetProgress(100);
  MsgFlowSize(Count);
  SetWorkFlag(false);
  glProgress := false;
end;
{$Q+}




function TDevItem.RdDevInfo(DevName : pchar; var TabVec: cardinal): TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  i  : integer;
  Reclen : integer;
begin
  Q[0]:=FDevNr;
  Q[1]:=40;
  Reclen := 16;
  Result:=Konwers(Q,2,QA,Reclen);
  if Result=stOk then
    if not((qa[0]=FDevNr) and (qa[1]=40)) then
      Result := stBadRepl;
  if Result=stOk then
  begin
    for i:=0 to 7 do
    begin
      DevName^:= chr(qa[i+2]);
      inc(DevName);
    end;
    DevName^:= #0;
    TabVec := qa[10] shl 24;
    TabVec := TabVec or (qa[11] shl 16);
    TabVec := TabVec or (qa[12] shl 8);
    TabVec := TabVec or qa[13];
  end;
end;

function TDevItem.RdCtrlByte(Nr: byte; var Val : byte):TStatus;
var
  Q  :  TByteAr;
  QA : TByteAr;
begin
  Q[0]:=FDevNr;
  Q[1]:=43;
  Q[2]:=Nr;
  Result:=Konwers(Q,3,QA);
  Val := qa[3];
end;

function TDevItem.WrCtrlByte(Nr: byte; Val : byte):TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  RecLen : integer;
begin
  Q[0]:=FDevNr;
  Q[1]:=44;
  Q[2]:=Nr;
  Q[3]:=Val;
  RecLen := 5;
  Result:=Konwers(Q,4,QA,RecLen);
end;


function    TDevItem.TerminalSendKey(key : char):TStatus;
var
  Q      : TByteAr;
  QA     : TByteAr;
  RecLen : integer;
begin
  Q[0]:=FDevNr;
  Q[1]:=45;
  Q[2]:=ord(key);
  RecLen := 4;
  Result:=Konwers(Q,3,QA,RecLen);
end;



function  TDevItem.TerminalRead(buf : pchar; var rdcnt : integer):TStatus;
var
  Q      : TByteAr;
  QA     : TByteAr;
  RecLen : integer;
begin
  Q[0]:=FDevNr;
  Q[1]:=46;
  RecLen:=0;

  Result:=Konwers(1,Q,2,QA,RecLen);
  if Result=stBadRepl then
  begin
    Q[0]:=FDevNr;
    Q[1]:=47;
    RecLen:=0;
    Result:=Konwers(Q,2,QA,RecLen);
  end;

  if Result=stOk then
  begin
    rdcnt:=RecLen-4;
    if rdcnt<0 then rdcnt:=0;
    if rdcnt>0 then
      move(QA[2],buf^,rdcnt);
  end
  else
    rdcnt:=0;
end;



const
  crdOpenSesion   = 50;
  crdCloseSesion  = 51;
  crdOpenFile     = 52;
  crdGetDirs      = 53;
//  crdGetErrorStr  = 54;
  crdGetDriveList = 55;
  crdShell        = 56;
  crdReadEx       = 57;
  crdGetGuidEx    = 58;
  crdGetErrorStr  = 59;

  crdRead         = 64;          //wymagaja podania FileNr
  crdWrite        = 65;
  crdSeek         = 66;
  crdGetFileSize  = 67;
  crdClose        = 68;         //ostatnia komenda z grupy FILE
  crdGetGuid      = 69;

  MAX_DATA_BUF_SIZE      = MAX_MDB_FRAME_SIZE-4;

type
// struktura zapytania z kana�u komunikacyjnego

  FSTR160 = array[0..159] of char;
  FSTR236 = array[0..235] of char;
  BUF234  = array[0..233] of char;

  PSEAskFrame = ^TSEAskFrame;
  TSEAskFrame = packed record
    AskCnt   : word;
    SesionID : cardinal;
  end;

  PSEAskFrameWr = ^TSEAskFrameWr;
  TSEAskFrameWr = packed record
    AskCnt   : word;
    SesionID : cardinal;
    FileNr   : byte;
    Free     : byte;
    Buf      : BUF234;
  end;

  PSEAskFrameCmd = ^TSEAskFrameCmd;
  TSEAskFrameCmd = packed record
    AskCnt   : word;
    SesionID : cardinal;
    Command  : FSTR236;
  end;

  PSEAskFrameFile = ^TSEAskFrameFile;
  TSEAskFrameFile = packed record
    AskCnt   : word;
    SesionID : cardinal;
    FileNr : byte;
    BArg1  : byte;
    Arg1   : cardinal;
  end;

  PSEAskFrameOpenFile = ^TSEAskFrameOpenFile;
  TSEAskFrameOpenFile = packed record
    AskCnt   : word;
    SesionID : cardinal;
    OpenMode : byte;
    Free     : byte;
    FName    : FSTR160;
  end;

  PSEAskFrameReadEx = ^TSEAskFrameReadEx;
  TSEAskFrameReadEx = packed record
    AskCnt     : word;
    SesionID   : cardinal;
    AutoClose  : byte;
    SizeToRead : byte;
    FName      : FSTR160;
  end;

  PSEAskFrameError = ^TSEAskFrameError;
  TSEAskFrameError = packed record
    ErrCode  : smallint;
  end;

  PSEAskFrameDir = ^TSEAskFrameDir;
  TSEAskFrameDir = packed record
    AskCnt   : word;
    SesionID : cardinal;
    First    : byte;
    Attrib   : byte;
    Free     : smallint;
    Name     : FSTR160;
  end;

  PSERplFrame = ^TSERplFrame;
  TSERplFrame = packed record
    Arg1 : cardinal;
  end;

  PSERplFrameOpen = ^TSERplFrameOpen;
  TSERplFrameOpen = packed record
    FileNr : byte;
    Free   : byte
  end;


function  TDevItem.GetNewAskNr : word;
begin
  inc(FAskNumber);
  Result := FAskNumber;
end;

function  TDevItem.GetErrStr(Code :TStatus; Buffer : pchar; MaxLen : integer):boolean;

var
  Q  : TByteAr;
  QA : TByteAr;
  P  : PSEAskFrameError;
  st : TStatus;
begin
  Q[0]:=FDevNr;
  Q[1]:=crdGetErrorStr;
  P := PSEAskFrameError(@Q[2]);
  P^.ErrCode := swap(Code);
  st:=Konwers(Q,2+sizeof(p^),QA);
  if st=stOk then
  begin
    StrLCopy(Buffer,pchar(@QA[2]),MaxLen);
  end;
  Result := (st=stOk);
end;

function  TDevItem.SeOpenSesion(var SesId : TSesID) : TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  P  : PSEAskFrame;
begin
  Q[0]:=FDevNr;
  Q[1]:=crdOpenSesion;
  P := PSEAskFrame(@Q[2]);
  P^.AskCnt := Swap(GetNewAskNr);
  Result:=Konwers(Q,2+2,QA);
  if Result = stOk then
    SesId := GetDWord(QA[2]);
end;

function  TDevItem.SeCloseSesion(SesId : TSesID) : TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  P  : PSEAskFrame;
begin
  Q[0]:=FDevNr;
  Q[1]:=crdCloseSesion;
  P := PSEAskFrame(@Q[2]);
  P^.AskCnt := Swap(GetNewAskNr);
  P^.SesionID := DSwap(SesId);
  Result:=Konwers(Q,2+sizeof(P^),QA);
end;

function  TDevItem.SeOpenFile(SesId : TSesID; FName : pchar; Mode : byte; var FileNr : TFileNr):TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  P  : PSEAskFrameOpenFile;
  L  : integer;
begin
  Q[0]:=FDevNr;
  Q[1]:=crdOpenFile;
  P := PSEAskFrameOpenFile(@Q[2]);
  P^.AskCnt := Swap(GetNewAskNr);
  P^.SesionID := DSwap(SesId);
  P^.OpenMode := Mode;
  StrLCopy(P^.FName,FName,sizeof(P^.FName));
  L := 2+4+2+strlen(FName)+1;
  Result:=Konwers(Q,2+L,QA);
    FileNr := QA[2];
end;

function  TDevItem.SeGetDirHd(First : boolean; SesId : TSesID; FName : pchar; Attrib : byte;
   Buffer : pchar; MaxLen : integer; var Len : integer):TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  P  : PSEAskFrameDir;
  RecLen : integer;
  L      : integer;
begin
  Q[0]:=FDevNr;
  Q[1]:=crdGetDirs;
  P := PSEAskFrameDir(@Q[2]);
  P^.AskCnt := Swap(GetNewAskNr);
  P^.SesionID := DSwap(SesId);
  if First then
  begin
    P^.First := 1;
    P^.Attrib   := Attrib;
    P^.Free     := 0;
    StrLCopy(P^.Name,FName,sizeof(P^.Name));
    L := 2+4+4+strlen(FName)+1;
  end
{
  TSEAskFrameDir = packed record
    AskCnt   : word;
    SesionID : cardinal;
    First    : byte;
    Attrib   : byte;
    Free     : smallint;
    Name     : FSTR160;
  end;
}
  else
  begin
    P^.First := 0;
    L := 2+4+1;
  end;
  RecLen:=0;
  Result:=Konwers(Q,2+L,QA,RecLen);
  if Result=stOk then
  begin
    Len := RecLen-4;
    if Len>MaxLen then
      Len := MaxLen;
    if Len<>0 then
      move(QA[2],Buffer^,Len);
  end;
end;

function  TDevItem.SeGetDir(SesId : TSesID; FName : pchar; Attrib : byte; Buffer : pchar; MaxLen : integer):TStatus;
var
  Len   : integer;
  pch   : pchar;
begin
  pch := Buffer;
  Result := SeGetDirHd(true,SesId,FName,Attrib,pch,MaxLen,Len);
  while (Result=stOk) and (Len<>0)  and (MaxLen<>0) do
  begin
    pch := @pch[Len];
    dec(MaxLen,Len);

    if pch[-1]=#0 then
    begin
      break;
    end;

    Result := SeGetDirHd(false,SesId,FName,Attrib,pch,MaxLen,Len);
  end;
  // dopisanie zera gdyby nie by�o
  if (pch[-1]<>#0) and (Maxlen<>0) then
  begin
    pch[0]:=#0;
  end;

  if MaxLen=0 then
    Result:= stBufferToSmall;

  if Result=stEND_OFF_DIR then
    Result:= stOK;

end;

function  TDevItem.SeGetDrvList(SesId : TSesID; DrvList : pchar):TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  P  : PSEAskFrame;
begin
  Q[0]:=FDevNr;
  Q[1]:=crdGetDriveList;
  P := PSEAskFrame(@Q[2]);
  P^.AskCnt := Swap(GetNewAskNr);
  P^.SesionID := DSwap(SesId);
  Result:=Konwers(Q,2+sizeof(P^),QA);
  if Result=stOk then
  begin
    StrLCopy(DrvList,pchar(@QA[2]),20);
  end;
end;

function  TDevItem.SeShell(SesId : TSesID; Command : pchar; ResultStr : pchar; MaxLen : integer):TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  P  : PSEAskFrameCmd;
  L  : integer;
begin
  Q[0]:=FDevNr;
  Q[1]:=crdShell;
  P := PSEAskFrameCmd(@Q[2]);
  P^.AskCnt := Swap(GetNewAskNr);
  P^.SesionID := DSwap(SesId);
  StrLCopy(P^.Command,Command,sizeof(P^.Command));
  L := 2+4+strlen(Command)+1;
  Result:=Konwers(Q,2+L,QA);
  if Result=stOk then
  begin
    if (MaxLen>0) and Assigned(ResultStr) then
      StrLCopy(ResultStr,pchar(@QA[2]),MaxLen);
  end;
end;

function TDevItem.SeReadFileEx(SesId : TSesID; FileName : pchar; autoclose: boolean; var buf;
              var size: integer; var FileNr: TFileNr):TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  P  : PSEAskFrameReadEx;
  L  : integer;
  RecLen : integer;
begin
  Q[0]:=FDevNr;
  Q[1]:=crdReadEx;
  P := PSEAskFrameReadEx(@Q[2]);
  P^.AskCnt := Swap(GetNewAskNr);
  P^.SesionID := DSwap(SesId);
  P^.AutoClose := Byte(autoclose);
  if Size>MAX_MDB_FRAME_SIZE then
     Size:=MAX_MDB_FRAME_SIZE;
  P^.SizeToRead := Size;
  StrLCopy(P^.FName,FileName,sizeof(P^.FName));
  L := 2+4+2+strlen(FileName)+1;
  RecLen:=0;
  Result:=Konwers(Q,2+L,QA,RecLen);
  if Result=stOk then
  begin
    RecLen := RecLen-6;   // cztery bajty z przodu i CRC z ty�u
    if RecLen>Size then
      RecLen:=Size;
    move(QA[4],buf,RecLen);
    FileNr:=QA[2];
    size := RecLen;
  end;
end;

function TDevItem.SeGetGuidEx(SesId : TSesID; FileName : pchar; var Guid : TSeGuid):TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  P  : PSEAskFrameOpenFile;
  L  : integer;
begin
  Q[0]:=FDevNr;
  Q[1]:=crdGetGuidEx;
  P := PSEAskFrameOpenFile(@Q[2]);
  P^.AskCnt := Swap(GetNewAskNr);
  P^.SesionID := DSwap(SesId);
  P^.OpenMode := 0;
  P^.Free := 0;
  StrLCopy(P^.FName,FileName,sizeof(P^.FName));
  L := 2+4+2+strlen(FileName)+1;
  Result:=Konwers(Q,2+L,QA);
  Guid.d1:=DSwap(pCardinal(@QA[2])^);
  Guid.d2:=DSwap(pCardinal(@QA[6])^);
end;

function  TDevItem.SeReadFileHd(SesId : TSesID;  FileNr : TFileNr; var buf; var Cnt : integer):TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  P  : PSEAskFrameFile;
  L  : integer;
  RecLen : integer;
begin
  Q[0]:=FDevNr;
  Q[1]:=crdRead;
  P := PSEAskFrameFile(@Q[2]);
  P^.AskCnt := Swap(GetNewAskNr);
  P^.SesionID := DSwap(SesId);
  P^.FileNr := FileNr;
  P^.BArg1  := 0;
  L := Cnt;
  if L>MAX_DATA_BUF_SIZE then
    L := MAX_DATA_BUF_SIZE;
  P^.Arg1   := DSwap(L);
  RecLen:=0;
  Result:=Konwers(Q,2+sizeof(P^),QA,RecLen);
  if Result=stOk then
  begin
    dec(RecLen,4);  // dwa bajty z przodu i CRC z ty�u
    if RecLen>Cnt then
      RecLen := Cnt;
    Move(QA[2],buf,RecLen);
    Cnt := RecLen;
  end;
end;

function TDevItem.SeReadFile(SesId : TSesID;  FileNr : TFileNr; var buf; var Cnt : integer):TStatus;
var
  Cnt1 : integer;
  CntS : integer;
  p    : pByte;
begin
  glProgress := true;
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);
  p := pByte(@buf);
  CntS := 0;
  repeat
    Cnt1:=Cnt-CntS;
    Result := SeReadFileHd(SesId,FileNr,p^,Cnt1);
    if Result=stOK then
    begin
      inc(CntS,Cnt1);
      inc(p,cnt1);
    end;
    SetProgress(CntS,Cnt);
    MsgFlowSize(CntS);
  until (Result<>stOK) or (Cnt=CntS) or (cnt1=0);
  Cnt := CntS;
  SetProgress(100);
  MsgFlowSize(Cnt);
  SetWorkFlag(false);
  glProgress := false;
end;

function  TDevItem.SeWriteFileHd(SesId : TSesID; FileNr : TFileNr; const buf; var Cnt : integer):TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  P  : PSEAskFrameWr;
  L  : integer;
  RecLen : integer;
  HS : integer;
begin
  Q[0]:=FDevNr;
  Q[1]:=crdWrite;
  P := PSEAskFrameWr(@Q[2]);
  P^.AskCnt := Swap(GetNewAskNr);
  P^.SesionID := DSwap(SesId);
  P^.FileNr := FileNr;
  P^.Free   := 0;
  HS := sizeof(P^)-sizeof(BUF234);
  L := Cnt;
  if L>MAX_DATA_BUF_SIZE-HS then
    L := MAX_DATA_BUF_SIZE-HS;
  Move(buf,Q[2+HS],L);
  RecLen:=0;
  Result:=Konwers(Q,2+HS+L,QA,RecLen);
  if (Result=stOk) and (RecLen>=8) then
  begin
    Cnt := GetLongInt(QA[2]);
  end
  else
    Cnt := 0;
end;

function  TDevItem.SeWriteFile(SesId : TSesID; FileNr : TFileNr; const buf; var Cnt : integer):TStatus;
var
  Cnt1 : integer;
  CntS : integer;
  p    : pByte;
begin
  glProgress := true;
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);
  p := pByte(@buf);
  CntS := 0;
  repeat
    Cnt1:=Cnt-CntS;
    Result := SeWriteFileHd(SesId,FileNr,p^,Cnt1);
    if Result=stOK then
    begin
      inc(p,cnt1);
      inc(CntS,Cnt1);
    end;
    SetProgress(CntS,Cnt);
    MsgFlowSize(CntS);
  until (Result<>stOK) or (Cnt=CntS);
  Cnt := CntS;
  SetProgress(100);
  MsgFlowSize(Cnt);
  SetWorkFlag(false);
  glProgress := false;
end;

function  TDevItem.SeSeek(SesId : TSesID; FileNr : TFileNr; Offset  : integer; Orgin : byte; var Pos : integer):TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  P  : PSEAskFrameFile;
begin
  Q[0]:=FDevNr;
  Q[1]:=crdSeek;
  P := PSEAskFrameFile(@Q[2]);
  P^.AskCnt := Swap(GetNewAskNr);
  P^.SesionID := DSwap(SesId);
  P^.FileNr := FileNr;
  P^.BArg1  := Orgin;
  P^.Arg1   := DSwap(Cardinal(Offset));
  Result:=Konwers(Q,2+sizeof(P^),QA);
  if Result=stOk then
  begin
    Pos := GetLongInt(QA[2]);
  end;
end;

function  TDevItem.SeGetFileSize(SesId : TSesID; FileNr : TFileNr; var FileSize : integer):TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  P  : PSEAskFrameFile;
begin
  Q[0]:=FDevNr;
  Q[1]:=crdGetFileSize;
  P := PSEAskFrameFile(@Q[2]);
  P^.AskCnt := Swap(GetNewAskNr);
  P^.SesionID := DSwap(SesId);
  P^.FileNr := FileNr;
  Result:=Konwers(Q,2+2+4+1,QA);
  if Result=stOk then
  begin
    FileSize := GetLongInt(QA[2]);
  end;
end;


function  TDevItem.SeCloseFile(SesId : TSesID;  FileNr : TFileNr):TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  P  : PSEAskFrameFile;
begin
  Q[0]:=FDevNr;
  Q[1]:=crdClose;
  P := PSEAskFrameFile(@Q[2]);
  P^.AskCnt := Swap(GetNewAskNr);
  P^.SesionID := DSwap(SesId);
  P^.FileNr := FileNr;
  Result:=Konwers(Q,2+2+4+1,QA);
end;


function  TDevItem.SeGetGuid(SesId : TSesID;  FileNr : TFileNr; var Guid : TSeGuid):TStatus;
var
  Q  : TByteAr;
  QA : TByteAr;
  P  : PSEAskFrameFile;
begin
  Q[0]:=FDevNr;
  Q[1]:=crdGetGuid;
  P := PSEAskFrameFile(@Q[2]);
  P^.AskCnt := Swap(GetNewAskNr);
  P^.SesionID := DSwap(SesId);
  P^.FileNr := FileNr;
  Result:=Konwers(Q,2+2+4+1,QA);
  Guid.d1:=DSwap(pCardinal(@QA[2])^);
  Guid.d2:=DSwap(pCardinal(@QA[6])^);
end;


//---------------------  TDevAcces ---------------------------
constructor TDevAcces.Create;
begin
  inherited Create;
  FCurrId := TAccId(1);
  InitializeCriticalSection(FCriSection);
end;


destructor  TDevAcces.Destroy;
begin
  DeleteCriticalSection(FCriSection);
  inherited;
end;

function TDevAcces.GetBoudRate(BdTxt: shortstring; var Baund :TBaudRate) : boolean;
begin
  Result := True;
       if BdTxt= '110'    then Baund := br110
  else if BdTxt= '300'    then Baund := br300
  else if BdTxt= '600'    then Baund := br600
  else if BdTxt= '1200'   then Baund := br1200
  else if BdTxt= '2400'   then Baund := br2400
  else if BdTxt= '4800'   then Baund := br4800
  else if BdTxt= '9600'   then Baund := br9600
  else if BdTxt= '14400'  then Baund := br14400
  else if BdTxt= '19200'  then Baund := br19200
  else if BdTxt= '38400'  then Baund := br38400
  else if BdTxt= '56000'  then Baund := br56000
  else if BdTxt= '57600'  then Baund := br57600
  else if BdTxt= '115200' then Baund := br115200
  else Result := false;
end;

function TDevAcces.GetMdbMode(BdTxt: shortstring; var MdbMode:TMdbMode) : boolean;
begin
  Result := True;
       if BdTxt= 'RTU'    then MdbMode := mdbRTU
  else if BdTxt= 'ASCII'  then MdbMode := mdbASCII
  else Result := false;
end;

function TDevAcces.GetParity(BdTxt: shortstring; var Parity:TParity) : boolean;
begin
  Result := True;
       if BdTxt= 'N'  then Parity := paNONE
  else if BdTxt= 'E'  then Parity := paEVEN
  else if BdTxt= 'O'  then Parity := paODD
  else Result := false;
end;

function TDevAcces.GetTocken(s : pChar; var p: integer):shortstring;
begin
  Result :='';
  while (s[p]<>';') and (s[p]<>#0) and (p<=length(s)) do
  begin
    Result := Result+s[p];
    inc(p);
  end;
  inc(p);
end;

function TDevAcces.GetId:TAccId;
begin
  Result := FCurrId;
  inc(FCurrId);
end;

//  MCOM;nr_rs;nr_dev;rs_speed;[ASCII|RTU];[N|E|O]
//  MCOM;1;7;115200;RTU;N

function TDevAcces.AddAcc(ConnectStr : pchar): TAccId;
var
  s       : shortstring;
  p       : integer;
  ComNr   : TComPort;
  DevNr   : integer;
  BaudRate: TBaudRate;
  OkStr   : boolean;
  DevItem : TDevItem;
  MdbMode : TMdbMode;
  Parity  : TParity;
begin
  Result := -1;
  p := 0;
  s := GetTocken(ConnectStr,p);
  if s='MCOM' then
  begin
    MdbMode := mdbRTU;
    Parity  := paNONE;
    BaudRate := br115200;


    s := GetTocken(ConnectStr,p);
    OkStr := True;
    try
      ComNr := TComPort(StrToInt(s));
    except
      ComNr := 1;
      OkStr := False;
    end;

    try
      s := GetTocken(ConnectStr,p);
      DevNr:=StrToInt(s);
    except
      DevNr:=255;
      OkStr := False;
    end;

    s := GetTocken(ConnectStr,p);
    if s<>'' then
    begin
      OkStr := GetBoudRate(s,BaudRate);
    end;

    s := GetTocken(ConnectStr,p);
    if s<>'' then
    begin
      OkStr := GetMdbMode(s,MdbMode);
    end;

    s := GetTocken(ConnectStr,p);
    if s<>'' then
    begin
      OkStr := GetParity(s,Parity);
    end;

    if OkStr then
    begin
      try
        EnterCriticalSection(FCriSection);
        Devitem := TDevItem.Create(GetId,ComNr,DevNr,BaudRate,MdbMode,Parity);
        Add(DevItem);
        Result := DevItem.AccID;
      finally
        LeaveCriticalSection(FCriSection);
      end;
    end
  end;
end;


function TDevAcces.DelAcc(AccId : TAccId):TStatus;
var
  i : integer;
  T : TDevItem;
begin
  Result := stBadId;
  try
    EnterCriticalSection(FCriSection);
    for i:=0 to Count-1 do
    begin
      T := TDevItem(Items[i]);
      if T.AccID=AccId then
      begin
        T.Close;
        Delete(i);
        T.Free;
        Result := stOk;
        Break;
      end;
    end;
  finally
    LeaveCriticalSection(FCriSection);
  end;
end;

function TDevAcces.FindId(AccId : TAccId):TDevItem;
var
  i : integer;
  T : TDevItem;
begin
  Result := nil;
  if AccId>=0 then
  begin
    try
      EnterCriticalSection(FCriSection);
      for i:=0 to Count-1 do
      begin
        T := TDevItem(Items[i]);
        if T.AccID=AccId then
        begin
          Result := T;
          Break;
        end;
      end;
    finally
      LeaveCriticalSection(FCriSection);
    end;
  end;
end;



//  -------------------- Export ---------------------------------------------


procedure LibIdentify(var LibGuid :TGUID); stdcall;
begin
  LibGuid := CommLibGuid;
end;

function  GetLibProperty:pchar; stdcall;
begin
  case EmulateVer of
  1 : result := pchar(LibPropertyStrV2);
  else
    result := pchar(LibPropertyStr);
  end;
end;

procedure SetEmulateVer(Ver : integer);
begin
  EmulateVer := Ver;
end;

function AddDev(ConnectStr : pchar): TAccId; stdcall;
begin
  Result := GlobDevAcces.AddAcc(ConnectStr);
end;

function DelDev(Id :TAccId):TStatus; stdcall;
begin
  Result := GlobDevAcces.DelAcc(Id);
end;

function  GetDrvStatus(Id :TAccId; ParamName : pchar; ParamValue :pchar; MaxRpl:integer): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.GetDrvStatus(ParamName,ParamValue,MaxRpl)
  else
    Result := stBadId;
end;

function  SetDrvParam(Id :TAccId; ParamName : pchar; ParamValue :pchar): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SetDrvParam(ParamName,ParamValue)
  else
    Result := stBadId;
end;

function  SetBreakFlag(Id :TAccId; Val:boolean): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SetBreakFlag(Val)
  else
    Result := stBadId;
end;

function  GetPortHandle(Id :TAccId): THandle;  stdcall;
var
  Dev : TDevItem;
begin
  Result := INVALID_HANDLE_VALUE;
  if GlobDevAcces<>nil then
  begin
    Dev := GlobDevAcces.FindId(Id);
    if Dev<>nil then
      Result := Dev.ComHandle;
  end
end;

function  RegisterCallBackFun(Id :TAccId; CmmId : integer; CallBackFunc : TCallBackFunc): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
  begin
    Dev.RegisterCallBackFun(CallBackFunc,CmmId);
    Result := stOk;
  end
  else
    Result := stBadId;
end;

function OpenDev(Id :TAccId):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.Open
  else
    Result := stBadId;
end;

procedure  CloseDev(Id :TAccId); stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
  begin
    Dev.Close;
  end;
end;

function GetDevNr(Id :TAccId):byte; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.DevNr
  else
    Result := 255;
end;

// Funkcje standardowe Modbus
function  RdOutTable(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.RdOutTable(Buf,Adress,Count);
  end
  else
    Result := stBadId;
end;

function  RdInpTable(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.RdInpTable(Buf,Adress,Count);
  end
  else
    Result := stBadId;
end;

function  RdReg(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.RdReg(Buf,Adress,Count);
  end
  else
    Result := stBadId;
end;

function  RdAnalogInp(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.RdAnalogInp(Buf,Adress,Count);
  end
  else
    Result := stBadId;
end;

function  WrOutput(Id :TAccId; Adress : word; Val : word):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.WrOutput(Adress,Val<>0);
  end
  else
    Result := stBadId;
end;

function  WrReg(Id :TAccId; Adress : word; Val : word):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.WrReg(Adress,Val);
  end
  else
    Result := stBadId;
end;

function  WrMultiReg(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.WrMultiReg(Buf,Adress,Count);
  end
  else
    Result := stBadId;
end;



// Funkcje odczytu, zapisu pami�ci
function ReadS(Id :TAccId;var  S; var Vec : Cardinal): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.RdDevInfo(pchar(@s),Vec);
  end
  else
    Result := stBadId;
end;


function ReadMem(Id :TAccId; var Buffer; adr : Cardinal; size : Cardinal): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.RdMemory(Buffer,Adr,Size)
  else
    Result := stBadId;
end;

function WriteMem(Id :TAccId; var Buffer; adr : Cardinal; Size : Cardinal): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.WrMemory(Buffer,Adr,Size)
  else
    Result := stBadId;
end;



function WriteCtrl(Id :TAccId; nr: byte; b: byte): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.WrCtrlByte(Nr,b)
  else
    Result := stBadId;
end;

function ReadCtrl(Id :TAccId; nr : byte; var b : byte): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.RdCtrlByte(Nr,b)
  else
    Result := stBadId;
end;


function TerminalSendKey(Id :TAccId; key : char):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.TerminalSendKey(key)
  else
    Result := stBadId;
end;


function  TerminalRead(Id :TAccId; buf : pchar; var rdcnt : integer):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.TerminalRead(buf,rdcnt)
  else
    Result := stBadId;
end;


function  SeOpenSesion(Id :TAccId; var SesId : TSesID) : TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SeOpenSesion(SesId)
  else
    Result := stBadId;
end;

function  SeCloseSesion(Id :TAccId; SesId : TSesID) : TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SeCloseSesion(SesId)
  else
    Result := stBadId;
end;

function  SeOpenFile(Id :TAccId; SesId : TSesID; FName : pchar; Mode : byte; var FileNr : TFileNr):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SeOpenFile(SesId,FName,Mode,FileNr)
  else
    Result := stBadId;
end;

function  SeGetDir(Id :TAccId; SesId : TSesID; FName : pchar; Attrib : byte; Buffer : pchar; MaxLen : integer):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SeGetDir(SesId,FName,Attrib,Buffer,MaxLen)
  else
    Result := stBadId;
end;

function  SeGetDrvList(Id :TAccId; SesId : TSesID; DrvList : pchar):TStatus;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SeGetDrvList(SesId,DrvList)
  else
    Result := stBadId;
end;

function  SeShell(Id :TAccId; SesId : TSesID; Command : pchar; ResultStr : pchar; MaxLen : integer):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SeShell(SesId ,Command,ResultStr,MaxLen)
  else
    Result := stBadId;
end;

function  SeReadFile(Id :TAccId; SesId : TSesID;  FileNr : TFileNr; var buf; var Cnt : integer):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SeReadFile(SesId,FileNr,Buf,Cnt)
  else
    Result := stBadId;
end;

function  SeWriteFile(Id :TAccId;  SesId : TSesID; FileNr : TFileNr; const buf; var Cnt : integer):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SeWriteFile(SesId,FileNr,Buf,Cnt)
  else
    Result := stBadId;
end;

function  SeSeek(Id :TAccId;  SesId : TSesID; FileNr : TFileNr; Offset  : integer; Orgin : byte; var Pos : integer):TStatus;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SeSeek(SesId,FileNr,Offset,Orgin,Pos)
  else
    Result := stBadId;
end;

function  SeGetFileSize(Id :TAccId;  SesId : TSesID; FileNr : TFileNr; var FileSize : integer):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SeGetFileSize(SesId,FileNr,FileSize)
  else
    Result := stBadId;
end;

function  SeCloseFile(Id :TAccId; SesId : TSesID;  FileNr : TFileNr):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SeCloseFile(SesId,FileNr)
  else
    Result := stBadId;
end;

function  SeGetGuid(Id :TAccId; SesId : TSesID;  FileNr : TFileNr; var Guid : TSeGuid):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SeGetGuid(SesId,FileNr,Guid)
  else
    Result := stBadId;
end;

function  SeGetGuidEx(Id :TAccId; SesId : TSesID; FileName : pchar; var Guid : TSeGuid):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SeGetGuidEx(SesId,FileName,Guid)
  else
    Result := stBadId;
end;

function  SeReadFileEx(Id :TAccId; SesId : TSesID; FileName : pchar; autoclose: boolean; var buf;
              var size: integer; var FileNr: TFileNr):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  Dev := GlobDevAcces.FindId(Id);
  if Dev<>nil then
    Result := Dev.SeReadFileEx(SesId,FileName,autoclose,buf,size,FileNr)
  else
    Result := stBadId;
end;


function  GetErrStr(Id :TAccId; Code :TStatus; S : pChar; Max: integer): boolean;  stdcall;
var
  Dev : TDevItem;
begin
  result := true;
  case Code of
  stOk              : strplcopy(S,'Ok',Max);
  stAttSemError     : strplcopy(S,'B��d semafora dost�powego',Max);
  stMaxAttachCom    : strplcopy(S,'Zbyt du�o otwartych dost�p�w.',Max);
  stSemafErr        : strplcopy(S,'B��d semafora dost�pu do portu.',Max);
  stCommErr         : strplcopy(S,'B��d otwarcia portu.',Max);
  stBadId           : strplcopy(S,'Po��czenie nie nawi�zane.',Max);
  stTimeErr         : strplcopy(S,'Time Out.',Max);
  stNotOpen         : strplcopy(S,'Port nie otwarty.',Max);
  stSetupErr        : strplcopy(S,'Z�e parametry portu.',Max);
  stUserBreak       : strplcopy(S,'Operacja przerwana.',Max);
  stNoSemafor       : strplcopy(S,'Brak dost�pu do semafora portu.',Max);
  stBadRepl         : strplcopy(S,'Nieprawid�owa odpowied� urz�dzenia.',Max);
  stBadArguments    : strplcopy(S,'Z�e argumenty dla zapytania MODBUS.',Max);
  else
    Result := false;
    if (Code>=stMdbError) and (Code<stMdbExError) then
    begin
      strplcopy(S,Format('B��d protoko�u MODBUS :%u',[Code-stMdbError]),Max);
      Result := true;
    end;
    if (Code>=stMdbExError) and (Code<stMdbExError+256) then
    begin
      strplcopy(S,Format('B��d protoko�u MODBUS_EX :%u',[Code-stMdbExError]),Max);
      Result := true;
    end;
  end;
  if not(Result) then
  begin
    Dev := GlobDevAcces.FindId(Id);
    if Dev<>nil then
      Result := Dev.GetErrStr(Code,S,Max);
  end;
  if not(result) then
  begin
    strplcopy(S,'B��d'+' '+IntToStr(Code),Max);
  end;
end;




initialization
  GlobDevAcces := TDevAcces.Create;
  IsMultiThread := True;  // Make memory manager thread safe

  EmulateVer := 0;
finalization
  GlobDevAcces.Free;
end.
