unit ThRsdUnit;

interface

uses
  Windows, Messages, SysUtils, Classes,
  GlobalMan;


const
  ComLibGuid     : TGUID ='{FAE45317-98B4-4F99-8682-2C822CDC5196}';
{
  LibPropertyStr : string =
    '<?xml version="1.0" standalone="yes"?>'+
    '<LIB_DESCR>'+
      '<INFO TYPE="RS" DESCR="£¹cze RS (protokó³ RSD)" SIGN="RCOM"/>'+
      '<PARAMS>'+
        '<PARAM DESCR="Nr portu" TYPE="COM_NR" DEFAULT="1" />'+
        '<PARAM DESCR="Nr urz¹dzenia" TYPE="BYTE" DEFAULT="255"/>'+
        '<PARAM DESCR="Szybkoœæ transmisji" TYPE="RS_SPEED" DEFAULT="115200"/>'+
      '</PARAMS>'+
    '</LIB_DESCR>';

  LibPropertyStrV2 : string =
    '<?xml version="1.0" standalone="yes"?>'+
    '<CMM_DESCR>'+
      '<CMM_INFO TYPE="RS" DESCR="£¹cze RS (protokó³ RSD)" SIGN="RCOM"/>'+
      '<GROUP>'+
        '<ITEM NAME="COM" TYPE="COM_NR" DESCR="Nr portu" DEFVALUE="1" />'+
        '<ITEM NAME="DEV_NR" TYPE="INT" DESCR="Nr urz¹dzenia" DEFVALUE="255" MIN="1" MAX="255" />'+
        '<ITEM NAME="RS_SPEED" TYPE="SELECT" DESCR="Szybkoœæ transmisji" DEFVALUE="115200" '+
            'ITEMS="115200|57600|56000|38400|19200|14400|9600|4800|2400|1200|600|300|110"/>'+
      '</GROUP>'+
    '</CMM_DESCR>';
}
  LibPropertyStr : string =
    '<?xml version="1.0" standalone="yes"?>'+
    '<LIB_DESCR>'+
      '<INFO TYPE="RS" DESCR="Port RS (protocol RSD)" SIGN="RCOM"/>'+
      '<PARAMS>'+
        '<PARAM DESCR="Port number" TYPE="COM_NR" DEFAULT="1" />'+
        '<PARAM DESCR="Device number" TYPE="BYTE" DEFAULT="255"/>'+
        '<PARAM DESCR="Baudrate" TYPE="RS_SPEED" DEFAULT="115200"/>'+
      '</PARAMS>'+
    '</LIB_DESCR>';

  LibPropertyStrV2 : string =
    '<?xml version="1.0" standalone="yes"?>'+
    '<CMM_DESCR>'+
      '<CMM_INFO TYPE="RS" DESCR="Port RS (protocol RSD)" SIGN="RCOM"/>'+
      '<GROUP>'+
        '<ITEM NAME="COM" TYPE="COM_NR" DESCR="Port number" DEFVALUE="1" />'+
        '<ITEM NAME="DEV_NR" TYPE="INT" DESCR="Device number" DEFVALUE="255" MIN="1" MAX="255" />'+
        '<ITEM NAME="RS_SPEED" TYPE="SELECT" DESCR="Baudrate" DEFVALUE="115200" '+
            'ITEMS="115200|57600|56000|38400|19200|14400|9600|4800|2400|1200|600|300|110"/>'+
      '</GROUP>'+
    '</CMM_DESCR>';
  wm_DevUser     = wm_User+1000;
  wm_OpenClose   = wm_DevUser+1;
  wm_WorkStatus  = wm_DevUser+2;
  wm_Progress    = wm_DevUser+3;

  evProgress  = 0;
  evFlow      = 1;
  evWorkOnOff = 4;

type
  TStatus   = integer;
  TAccId    = integer;

  TCallBackFunc = procedure(Id :TAccId; CmmId : integer; Ev : integer; R : real); stdcall;
procedure LibIdentify(var LibGuid :TGUID); stdcall;
function  GetLibProperty:pchar; stdcall;
procedure SetEmulateVer(Ver : integer); stdcall;
function  GetDrvStatus(Id :TAccId; ParamName : pchar; ParamValue :pchar; MaxRpl:integer): TStatus; stdcall;
function  SetDrvParam(Id :TAccId; ParamName : pchar; ParamValue :pchar): TStatus; stdcall;

function  AddDev(ConnectStr : pchar): TAccId; stdcall;
function  DelDev(Id :TAccId):TStatus; stdcall;
function  OpenDev(Id :TAccId):TStatus; stdcall;
function  RegisterCallBackFun(Id :TAccId; CmmId : integer; CallBackFunc : TCallBackFunc): TStatus; stdcall;

procedure CloseDev(Id :TAccId); stdcall;
function  GetDevNr(Id :TAccId):byte; stdcall;

function  ReadS(Id :TAccId; var S ; var Vec : Cardinal): TStatus; stdcall;
function  ReadMem(Id :TAccId; var Buffer; adr : Cardinal; size : Cardinal): TStatus; stdcall;
function  WriteMem(Id :TAccId; const Buffer; adr : Cardinal; Size : Cardinal): TStatus; stdcall;
function  WriteCtrl(Id :TAccId; nr: byte; b: byte): TStatus; stdcall;
function  ReadCtrl(Id :TAccId; nr : byte; var b : byte): TStatus; stdcall;
function  GetErrStr(Id :TAccId; Code :TStatus; S : pChar; Max: integer): boolean;  stdcall;
function  SemaforWr(Id :TAccId; nr: byte; b: byte): TStatus; stdcall;
function  SemaforRd(Id :TAccId; nr : byte; var b : byte): TStatus; stdcall;




function  ReadReg(Id :TAccId; var  Buffer): TStatus; stdcall;
function  FillMem(Id :TAccId; adr : Cardinal; size : word; Sign : byte): TStatus; stdcall;
function  MoveMem(Id :TAccId; src:Cardinal; Des:Cardinal; size : word): TStatus; stdcall;


function  GetPortHandle(Id :TAccId): THandle;  stdcall;
function  SetBreakFlag(Id :TAccId; Val:boolean): TStatus; stdcall;
procedure SetLanguage(LibName : pchar;Language:pchar;ServiceMode:integer); stdcall;

Exports
    LibIdentify,
    GetLibProperty,
    SetEmulateVer,
    SetBreakFlag,
    GetDrvStatus,
    SetDrvParam,

    AddDev,
    DelDev,
    OpenDev,
    CloseDev,
    GetDevNr,
    ReadS,
    ReadReg,
    ReadMem,
    WriteMem,
    FillMem,
    MoveMem,
    WriteCtrl,
    ReadCtrl,
    SemaforWr,
    SemaforRd,
    GetErrStr,
    RegisterCallBackFun,
    GetPortHandle,
    SetLanguage;



implementation

uses
  LangUnit;

Const
  REC_SIZE  = 240;
var
  Lang        : TXLangGroup;
  CountDivide : cardinal;
const
  TXT001 = 'TXT001';
  TXT002 = 'TXT002';
  TXT003 = 'TXT003';
  TXT004 = 'TXT004';
  TXT005 = 'TXT005';
  TXT006 = 'TXT006';
  TXT007 = 'TXT007';
  TXT008 = 'TXT008';
  TXT009 = 'TXT009';
  TXT010 = 'TXT010';
  TXT011 = 'TXT011';
  TXT012 = 'TXT012';
  TXT013 = 'TXT013';
  TXT014 = 'TXT014';

type
  TComPort   = integer;
  TBaudRate = (br110, br300, br600, br1200, br2400, br4800, br9600,
               br14400, br19200, br38400, br56000, br57600, br115200);

  TBuf      = array[0..$1ff] of byte;
  TGBuf     = array[0..$1fffff] of byte;

  TDevItem = class (TObject)
  private
    AccID       : integer;
    ComNr       : integer;
    FDevNr      : integer;
    BaudRate    : TBaudrate;
    ComHandle   : THandle;
    SemHandle   : THandle;
    ZioPower    : boolean;

    OwnerHandle : THandle;
    FWorking     : boolean;
    LastFinished : Cardinal;
    FLockStatus  : boolean;
    FrameCnt     : integer;
    FrameRepCnt  : integer;
    FCallBackFunc: TCallBackFunc;
    FCmmId       : integer;
    function GetComAcces: boolean;
    procedure ReleaseComAcces;

    function  RsWrite(var Buffer; Count: Integer): Integer;
    function  RsRead(var Buffer; Count: Integer): Integer;
    procedure PurgeInOut;
    function  Konwers(Tm: cardinal; Cnt:byte; var Buffer; WrCnt,RdCnt : integer; const InBuf; var OutBuf): TStatus; overload;
    function  Konwers(Tm: cardinal; Cnt:byte; var Buffer; WrCnt,RdCnt : integer; var OutBuf): TStatus; overload;
    function  Konwers(Tm: cardinal; Cnt:byte; var Buffer): TStatus; overload;
    function  ReadM(var Buffer; adr : Cardinal; size : byte): TStatus;
    function  WriteM(const Buffer; adr : Cardinal; size : byte): TStatus;
  protected
    procedure GoBackFunct(Ev: integer; R: real);
    procedure SetProgress(Proc: real); overload;
    procedure SetProgress(Cnt,Max:integer); overload;
    procedure MsgFlowSize(R: real);
    procedure SetWorkFlag(w : boolean);

    function  InQue: Integer;
    function  OutQue: Integer;
    procedure RsWriteByte(b : byte);
    procedure RsWriteWord(b : Word);
    function  RsReadByte(var b : byte):boolean;
  public
    BreakFlag : boolean;
    MaxTime   : integer;
    constructor Create(AId : TAccId; AComNr : TComPort; ADevNr: integer;ABaudRate :TBaudrate);
    destructor  Destroy; override;
    function    ValidHandle : boolean;
    function    SetupState: TStatus;
    function    Open : TStatus;
    procedure   Close;
    procedure   Break;
    function    ReadS(var Sign; var Vec : Cardinal): TStatus;
    function    ReadMem(var Buffer; adr : Cardinal; Size : Cardinal): TStatus;
    function    ReadReg(var Buffer): TStatus;
    function    WriteMem(const Buffer; adr : Cardinal; Size : Cardinal): TStatus;
    function    FillMem(adr : Cardinal; size : word; Sign : byte): TStatus;
    function    MoveMem(src:Cardinal; Des:Cardinal; size : word): TStatus;
    function    WriteCtrl(nr: byte; b: byte): TStatus;
    function    ReadCtrl(nr : byte; var b : byte): TStatus;
    procedure   RegisterCallBackFun(ACallBackFunc : TCallBackFunc; CmmId : integer);
    function    SetBreakFlag(Val:boolean): Tstatus;
    function    GetDrvStatus(ParamName : pchar; ParamValue :pchar; MaxRpl:integer): TStatus;
    function    SetDrvParam(ParamName : pchar; ParamValue :pchar): TStatus;
    property    DevNr  : integer read FDevNr;

  end;


  TDevAcces = class(TList)
  private
    FCurrId          : TAccId;
    FCriSection      : TRTLCriticalSection;
    function GetBoudRate(BdTxt: shortstring; var Baund :TBaudRate) : boolean;
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

  dcb_DtrControl_Enab  = $00000010;
  dcb_DtrControl_Hand  = $00000030;

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
constructor TDevItem.Create(AId : TAccId; AComNr : TComPort; ADevNr: integer;ABaudRate :TBaudrate);
begin
  inherited Create;
  AccID        := AId;
  ComNr        := AComNr;
  FDevNr       := ADevNr;
  BaudRate     := ABaudrate;
  OwnerHandle  := INVALID_HANDLE_VALUE;
  ComHandle    := INVALID_HANDLE_VALUE;
  LastFinished := GetTickCount;
  MaxTime      := 5000;
  FCallBackFunc:= nil;
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
  TabCharSize : array[TBaudRate] of integer= (192,64,32,16,8,4,2,1,1,1,1,1,1);

function TDevItem.SetupState: TStatus;
var
  DCB       : TDCB;
  Timeouts  : TCommTimeouts;
begin
  FillChar(DCB, SizeOf(DCB), 0);
  DCB.DCBlength := SizeOf(DCB);
  DCB.Flags    := DCB.Flags or dcb_Binary;
  if ZioPower then
  begin
    DCB.Flags  := DCB.Flags or dcb_DtrControl_Enab  or dcb_RtsControl;
  end;
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
  DCB.ByteSize := 8;

  Result := stSetupErr;
  if not SetCommState(ComHandle, DCB)         then    Exit;
  if not GetCommTimeouts(ComHandle, Timeouts) then    Exit;
{
  Timeouts.ReadIntervalTimeout := 5*TabCharSize[BaudRate];
  Timeouts.ReadTotalTimeoutMultiplier := 4*TabCharSize[BaudRate];
  Timeouts.ReadTotalTimeoutConstant := 400;
}
  Timeouts.ReadIntervalTimeout := MAXDWORD;
  Timeouts.ReadTotalTimeoutMultiplier := 0;
  Timeouts.ReadTotalTimeoutConstant := 0;

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
      if Result = stOk then
      begin
        if OwnerHandle<>0 then
          PostMessage(OwnerHandle,wm_OpenClose,1,0);
      end;
      ReleaseComAcces;
    end
    else
      Result := stNoSemafor;
  end;
end;

procedure TDevItem.Close;
var
  p : boolean;
begin
  p := (OwnerHandle<>0) and (ComHandle<>INVALID_HANDLE_VALUE);
  CloseCommHandle(ComNr);
  ComHandle:=INVALID_HANDLE_VALUE;
  SemHandle:=INVALID_HANDLE_VALUE;
  if p then
    PostMessage(OwnerHandle,wm_OpenClose,0,0);
end;

procedure  TDevItem.GoBackFunct(Ev: integer; R: real);
begin
  if Assigned(FCallBackFunc) then
    FCallBackFunc(AccID,FCmmID,Ev,R);
end;

procedure TDevItem.SetProgress(Proc: real);
begin
  GoBackFunct(evProgress,Proc);
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
begin
  FillChar(Overlapped, SizeOf(Overlapped), 0);
  Overlapped.hEvent := CreateEvent(nil, True, True, nil);
  WriteFile(ComHandle, Buffer, Count, BytesWritten, @Overlapped);

  WaitForSingleObject(Overlapped.hEvent, INFINITE);
  q := GetOverlappedResult(ComHandle, Overlapped, BytesWritten, False);
  CloseHandle(Overlapped.hEvent);
  Result := BytesWritten;
  if not(q) then Result := 0;
end;


procedure TDevItem.RsWriteByte(b : byte);
begin
  RsWrite(b,1);
end;

procedure TDevItem.RsWriteWord(b : Word);
begin
  RsWrite(b,2);
end;

function TDevItem.RsRead(var Buffer; Count: Integer): Integer;
var
  Overlapped : TOverlapped;
  BytesRead  : Cardinal;
  q          : boolean;
begin
  FillChar(Overlapped, SizeOf(Overlapped), 0);
  Overlapped.hEvent := CreateEvent(nil, True, True, nil);
  ReadFile(ComHandle, Buffer, Count, BytesRead, @Overlapped);
  WaitForSingleObject(Overlapped.hEvent, INFINITE);
  q:=GetOverlappedResult(ComHandle, Overlapped, BytesRead, False);
  CloseHandle(Overlapped.hEvent);
  Result := BytesRead;
  if not(q) then Result := 0;
end;



function  TDevItem.RsReadByte(var b : byte):boolean;
begin
  Result:=(RsRead(b,1)=1);
end;


procedure TDevItem.PurgeInOut;
begin
  PurgeComm(ComHandle, PURGE_RXABORT or PURGE_RXCLEAR or PURGE_TXABORT or PURGE_TXCLEAR);
end;



function TDevItem.Konwers(Tm: cardinal; Cnt:byte; var Buffer; WrCnt,RdCnt : integer; const InBuf; var OutBuf): TStatus;
var
  SndBuf   : TBuf;
  ToSndCnt : word;
  RecCnt   : word;

  procedure Shift2Buf(ComHandle: THandle);
  var
    bb   : TBuf;
    wsk  : word;
  begin
    cnt:=RsRead(bb,sizeof(bb));
    wsk:=0;
    while (wsk<>cnt) and (RecCnt<sizeof(TBuf)) do
    begin
      TBuf(Buffer)[RecCnt]:=bb[wsk];
      inc(wsk);
      inc(RecCnt);
    end;
  end;

  function CheckRamka: boolean;
  label
     ExitP;
   var
     xorb  : byte;
     i     : byte;
     Cnt   : byte;
   begin
     CheckRamka := false;
     if RecCnt<2                  then Goto ExitP;
     if TBuf(Buffer)[0]<>27       then Goto ExitP;
     if RecCnt<TBuf(Buffer)[1]+3  then Goto ExitP;
     cnt :=  TBuf(Buffer)[1];
     xorb := 0;
     for i:=1 to Cnt+2 do
     begin
       xorb := xorb xor TBuf(Buffer)[i];
     end;
     if xorb<>0 then Goto ExitP;
     CheckRamka := true;
   ExitP:
   end;

  function RecivAnsw(TmDelay : cardinal; ComHandle: THandle; DeviceNr:byte):boolean;
  var
    RecOk     : boolean;
    TimeOut   : boolean;
    StartTime : Cardinal;
    i         : byte;
    ch        : char;
    wsk       : integer;
  begin
    RecCnt   := 0;
    StartTime := GetTickCount;
    repeat
      Shift2Buf(ComHandle);
      RecOk:=CheckRamka;
      TimeOut:=(GetTickCount>StartTime+TmDelay);
      if not(RecOk) then
        Sleep(5);
    until RecOk or TimeOut;
    Result:= False;
    if RecOk then
    begin
      ch := chr(TBuf(Buffer)[2]);
      wsk :=0;
      case ch of
      'A':begin
            wsk:=3;
            Result := (DeviceNr=255);
          end;
      'a':begin
            wsk:=4;
            Result := (DeviceNr=TBuf(Buffer)[3]);
          end;
       end;
       if Result then
       begin
         i:=0;
         while (i<=RecCnt-3) and (i<RdCnt) do
         begin
           TBuf(OutBuf)[i]:=TBuf(Buffer)[wsk];
           inc(i);
           inc(wsk);
         end;
       end;
    end
  end;

  procedure SendPol(ComHandle: THandle);
  begin
    RsWrite(SndBuf,ToSndCnt);
  end;

  function MakeSndBuf(DevNr: byte;var Buffer; Cnt : byte;const DatBuf; DtCnt:byte):word;
  var
    i    : word;
    xorb : byte;
    wsk  : word;
  begin
    SndBuf[0]:=27;
    SndBuf[1]:=Cnt+DtCnt;
    SndBuf[2]:=TBuf(Buffer)[0];
    Wsk:=3;
    if DevNr<>255 then
    begin
      inc(SndBuf[1]);
      SndBuf[2] := SndBuf[2] or $20;
      SndBuf[3] := DevNr;
      inc(wsk);
    end;

    i:=1;
    while(i<Cnt) do
    begin
      SndBuf[wsk]:=TBuf(Buffer)[i];
      inc(wsk);
      inc(i);
    end;

    i :=0;
    while(i<DtCnt) do
    begin
      SndBuf[wsk]:=TBuf(DatBuf)[i];
      inc(wsk);
      inc(i);
    end;

    xorb :=0;
    for i:=1 to wsk-1 do
    begin
      xorb := xorb xor SndBuf[i];
    end;

    SndBuf[wsk]:=xorb;
    Result :=Wsk+1;
  end;

var
  rep       : byte;
  q         : boolean;
begin
  if not(ValidHandle) then
  begin
    Result := stNotOpen;
    Exit;
  end;
  if GetComAcces then
  begin
    FWorking := True;
    rep       := 3;
    ToSndCnt  := MakeSndBuf(FDevNr,Buffer,Cnt,InBuf,WrCnt);
    repeat
      q :=true;
      if not(BreakFlag) then
      begin
        PurgeInOut;
        inc(FrameCnt);
        while  GetTickCount-LastFinished<2 do
        begin
          sleep(1);
        end;
        SendPol(ComHandle);
        q := RecivAnsw(Tm,ComHandle,FDevNr);
        LastFinished := GetTickCount;
        if not(q) then
        begin
          inc(FrameRepCnt);
          dec(rep);
        end;
      end;
    until (rep=0) or q or BreakFlag;
    Result := stOk;
    if BreakFlag then
    begin
      Result := stUserBreak;
    end;
    if not(q) then
    begin
      Result := stTimeErr;
    end;
    FWorking := False;
    ReleaseComAcces;
  end
  else
    Result := stNoSemafor;
end;

function  TDevItem.Konwers(Tm : cardinal; Cnt:byte; var Buffer; WrCnt,RdCnt : integer; var OutBuf): TStatus;
var
  a : byte;
begin
  Result := Konwers(Tm,Cnt,Buffer,WrCnt,RdCnt,a,OutBuf);
end;

function TDevItem.Konwers(Tm : cardinal; Cnt:byte; var Buffer): TStatus;
var
  a : integer;
begin
  Result := Konwers(Tm,Cnt,Buffer,0,0,a,a);
end;

procedure  TDevItem.Break;
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


function TDevItem.ReadS(var Sign; var Vec : Cardinal): TStatus;
var
  bb  : TBuf;
  i   : integer;
  pch : pchar;
begin
  bb[0]:=ord('S');
  Result:=Konwers(180,1,bb,0,10,bb);
  Vec := bb[7];
  Vec := (Vec shl 8) or bb[6];
  Vec := (Vec shl 8) or bb[5];
  bb[5]:=0;
  pch := pchar(@Sign);
  for i:=0 to 4 do
  begin
    pch^:=char(bb[i]);
    inc(pch);
  end;
  pch^:=#0;
end;


function TDevItem.ReadM(var Buffer; adr : Cardinal; size : byte): TStatus;
var
  bb  : TBuf;
begin
  bb[0]:=ord('R');
  bb[1]:=lolo(adr);
  bb[2]:=lohi(adr);
  bb[3]:=hilo(adr);
  bb[4]:=Size;
  Result:=Konwers(1000,5,bb,0,Size,buffer);
end;

function TDevItem.ReadMem(var Buffer; adr : Cardinal; Size : Cardinal): TStatus;
var
  Wsk        : Cardinal;
  size1      : byte;
  adr1       : Cardinal;
  lst        : boolean;
  AllSize    : integer;
begin
  if CountDivide=0 then CountDivide := REC_SIZE;
  adr1 := adr;
  Wsk :=0;
  AllSize := Size;
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);
  FWorking := True;
  lst := FLockStatus;
  FLockStatus := true;
  repeat
    if Size>CountDivide then Size1 := CountDivide
                        else Size1 := Size;
    Result := ReadM(TGbuf(Buffer)[wsk],adr1,size1);
    inc(wsk,Size1);
    inc(adr1,Size1);
    dec(Size,Size1);
    SetProgress(wsk,AllSize);
    MsgFlowSize(wsk);
  until (Size=0) or (Result<>stOk) ;
  SetProgress(100);
  SetWorkFlag(false);
  FLockStatus:=lst;
  FWorking := False;
end;




function TDevItem.ReadReg(var Buffer): TStatus;
var
  bb : TBuf;
begin
  bb[0]:=ord('I');
  Result := Konwers(200,1,bb,0,4,Buffer);
end;

function TDevItem.WriteM(const Buffer; adr : Cardinal; size : byte): TStatus;
var
  bb      : Tbuf;
  nothing : byte;
begin
  bb[0]:=ord('W');
  bb[1]:=lolo(adr);
  bb[2]:=lohi(adr);
  bb[3]:=hilo(adr);
  bb[4]:=Size;
  Result := Konwers(1000,5,bb,Size,0,Buffer,nothing);
end;

function TDevItem.WriteMem(const Buffer; adr : Cardinal; Size : Cardinal): TStatus;
var
  size1   : byte;
  wsk     : Cardinal;
  lst     : boolean;
  AllSize : integer;
begin
  if CountDivide=0 then CountDivide := REC_SIZE;
  FWorking := True;
  lst := FLockStatus;
  FLockStatus := true;
  AllSize := Size;
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);
  wsk := 0;
  repeat
    if Size>CountDivide then Size1 := CountDivide
                        else Size1 := Size;
    Result:=WriteM(TGbuf(Buffer)[wsk],adr,size1);
    inc(wsk,Size1);
    inc(adr,Size1);
    dec(Size,Size1);
    SetProgress(wsk,AllSize);
    MsgFlowSize(wsk);
  until (Size=0) or (Result<>stOk);
  SetProgress(100);
  SetWorkFlag(false);
  FLockStatus:=lst;
  FWorking := False;
end;


function TDevItem.FillMem(adr : Cardinal; size : word; Sign : byte): TStatus;
var
  bb : TBuf;
begin
  bb[0]:=ord('F');
  bb[1]:=lolo(adr);
  bb[2]:=lohi(adr);
  bb[3]:=hilo(adr);
  bb[4]:=lo(Size);
  bb[5]:=hi(Size);
  bb[6]:=Sign;
  Result:=Konwers(200,7,bb);
end;

{'V',SrcL,SrcH,AdrM,DesL,DesH,DesM,SizeL,SizeH}
function TDevItem.MoveMem(src:Cardinal; Des:Cardinal; size : word): TStatus;
var
  bb : TBuf;
begin
  bb[0]:=ord('V');
  bb[1]:=lolo(src);
  bb[2]:=lohi(src);
  bb[3]:=hilo(src);
  bb[4]:=lolo(des);
  bb[5]:=lohi(des);
  bb[6]:=hilo(des);
  bb[7]:=lo(Size);
  bb[8]:=hi(Size);
  Result:=Konwers(200,9,bb);
end;

function TDevItem.WriteCtrl(nr: byte; b: byte): TStatus;
var
  bb : TBuf;
begin
  bb[0]:=ord('M');
  bb[1]:=nr;
  bb[2]:=b;
  Result:=Konwers(200,3,bb);
end;

function TDevItem.ReadCtrl(nr : byte; var b : byte): TStatus;
var
  bb : TBuf;
begin
  bb[0]:=ord('K');
  bb[1]:=nr;
  Result:=Konwers(200,2,bb,0,1,bb);
  b := bb[0];
end;

procedure  TDevItem.RegisterCallBackFun(ACallBackFunc : TCallBackFunc; CmmId : integer);
begin
  FCallBackFunc := ACallBackFunc;
  FCmmId := CmmId;
end;

function TDevItem.SetBreakFlag(Val:boolean): Tstatus;
begin
  BreakFlag := val;
  Result := stok;
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
  else if BdTxt= '115200' then Baund := br115200
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

//  COM;1;7;115200                 .nr_rs;nr_dev;rs_speed    .
function TDevAcces.AddAcc(ConnectStr : pchar): TAccId;
var
  s     : shortstring;
  p     : integer;
  ComNr : TComPort;
  DevNr : integer;
  BaudRate : TBaudRate;
  OkStr : boolean;
  DevItem : TDevItem;
begin
  Result := -1;
  p := 0;
  s := GetTocken(ConnectStr,p);
  if (s='COM') or (s='RCOM') then
  begin
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
    if not(GetBoudRate(s,BaudRate)) then
      BaudRate := br115200;
    if OkStr then
    begin
      try
        EnterCriticalSection(FCriSection);
        Devitem := TDevItem.Create(GetId,ComNr,DevNr,BaudRate);
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
  LibGuid := ComLibGuid;
end;

function  GetLibProperty:pchar; stdcall;
begin
  case EmulateVer of
  1 : result := pchar(LibPropertyStrV2);
  else
    result := pchar(LibPropertyStr);
  end;
end;

procedure SetEmulateVer(Ver : integer); stdcall;
begin
  EmulateVer := Ver;
end;


function AddDev(ConnectStr : pchar): TAccId; stdcall;
begin
  if GlobDevAcces<>nil then
    Result := GlobDevAcces.AddAcc(ConnectStr)
  else
    Result := stTerminate;
end;

function DelDev(Id :TAccId):TStatus; stdcall;
begin
  if GlobDevAcces<>nil then
    Result := GlobDevAcces.DelAcc(Id)
  else
    Result := stTerminate;
end;


function OpenDev(Id :TAccId):TStatus; stdcall;
var
  Dev : TDevItem;
begin
  if GlobDevAcces<>nil then
  begin
    Dev := GlobDevAcces.FindId(Id);
    if Dev<>nil then
      Result := Dev.Open
    else
      Result := stBadId;
  end
  else
    Result := stTerminate;
end;

procedure  CloseDev(Id :TAccId); stdcall;
var
  Dev : TDevItem;
begin
  if GlobDevAcces<>nil then
  begin
    Dev := GlobDevAcces.FindId(Id);
    if Dev<>nil then
    begin
      Dev.Close;
    end;
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

function ReadS(Id :TAccId; var S; var Vec : Cardinal): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  if GlobDevAcces<>nil then
  begin
    Dev := GlobDevAcces.FindId(Id);
    if Dev<>nil then
      Result := Dev.ReadS(S,Vec)
    else
      Result := stBadId;
  end
  else
    Result := stTerminate;
end;

function ReadReg(Id :TAccId; var  Buffer): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  if GlobDevAcces<>nil then
  begin
    Dev := GlobDevAcces.FindId(Id);
    if Dev<>nil then
      Result := Dev.ReadReg(Buffer)
    else
      Result := stBadId;
  end
  else
    Result := stTerminate;
end;

function ReadMem(Id :TAccId; var Buffer; adr : Cardinal; size : Cardinal): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  if GlobDevAcces<>nil then
  begin
    Dev := GlobDevAcces.FindId(Id);
    if Dev<>nil then
      Result := Dev.ReadMem(Buffer,Adr,Size)
    else
      Result := stBadId;
  end
  else
    Result := stTerminate;
end;

function WriteMem(Id :TAccId; const Buffer; adr : Cardinal; Size : Cardinal): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  if GlobDevAcces<>nil then
  begin
    Dev := GlobDevAcces.FindId(Id);
    if Dev<>nil then
      Result := Dev.WriteMem(Buffer,Adr,Size)
    else
      Result := stBadId;
  end
  else
    Result := stTerminate;
end;

function FillMem(Id :TAccId; adr : Cardinal; size : word; Sign : byte): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  if GlobDevAcces<>nil then
  begin
    Dev := GlobDevAcces.FindId(Id);
    if Dev<>nil then
      Result := Dev.FillMem(Adr,Size,Sign)
    else
      Result := stBadId;
  end
  else
    Result := stTerminate;
end;

function MoveMem(Id :TAccId; src:Cardinal; Des:Cardinal; size : word): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  if GlobDevAcces<>nil then
  begin
    Dev := GlobDevAcces.FindId(Id);
    if Dev<>nil then
      Result := Dev.MoveMem(Src,Des,Size)
    else
      Result := stBadId;
  end
  else
    Result := stTerminate;
end;

function WriteCtrl(Id :TAccId; nr: byte; b: byte): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  if GlobDevAcces<>nil then
  begin
    Dev := GlobDevAcces.FindId(Id);
    if Dev<>nil then
      Result := Dev.WriteCtrl(Nr,b)
    else
      Result := stBadId;
  end
  else
    Result := stTerminate;
end;

function SemaforWr(Id :TAccId; nr: byte; b: byte): TStatus; stdcall;
begin
  Result := WriteCtrl(Id,nr,b);
end;


function ReadCtrl(Id :TAccId; nr : byte; var b : byte): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  if GlobDevAcces<>nil then
  begin
    Dev := GlobDevAcces.FindId(Id);
    if Dev<>nil then
      Result := Dev.ReadCtrl(Nr,b)
    else
      Result := stBadId;
  end
  else
    Result := stTerminate;
end;

function  SemaforRd(Id :TAccId; nr : byte; var b : byte): TStatus; stdcall;
begin
  Result := ReadCtrl(Id,nr,b);
end;

function  RegisterCallBackFun(Id :TAccId; CmmId : integer; CallBackFunc : TCallBackFunc): TStatus; stdcall;
var
  Dev : TDevItem;
begin
  if GlobDevAcces<>nil then
  begin
    Dev := GlobDevAcces.FindId(Id);
    if Dev<>nil then
    begin
      Dev.RegisterCallBackFun(CallBackFunc,CmmId);
      Result := stOk;
    end
    else
      Result := stBadId;
  end
  else
    Result := stTerminate;
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
  if GlobDevAcces<>nil then
  begin
    Dev := GlobDevAcces.FindId(Id);
    if Dev<>nil then
      Result := Dev.SetBreakFlag(val)
    else
      Result := stBadId;
  end
  else
    Result := stTerminate;
end;

function TDevItem.GetDrvStatus(ParamName : pchar; ParamValue :pchar; MaxRpl:integer): TStatus;
  function Bool2Str(q :boolean): string;
  begin
    if q then Result := '1' else Result := '0';
  end;
var
  s : string;
begin
  s := '';
       if ParamName='REPEAT_CNT'  then s := IntToStr(FrameRepCnt)
  else if ParamName='FRAME_CNT'   then s := IntToStr(FrameCnt)
  else if ParamName='ZIO_POWER'   then s := Bool2Str(ZioPower);
{
  else if ParamName='WAIT_CNT'    then s := IntToStr(WaitCnt)
  else if ParamName='RECIVE_TIME' then s := IntToStr(SumRecTime)
  else if ParamName='SEND_TIME'   then s := IntToStr(SumSendTime);
}

  if s<>'' then
  begin
    StrPLCopy(ParamValue,s,MaxRpl);
    Result := stOK;
  end
  else
    Result := stBadArguments;
end;

function  TDevItem.SetDrvParam(ParamName : pchar; ParamValue :pchar): TStatus;
begin
  Result := stBadArguments;
  if ParamName='DIVIDE_LEN' then
  begin
    CountDivide := StrToIntDef(ParamValue,REC_SIZE);
    Result := stOk;
  end;
  if ParamName='ZIO_POWER' then
  begin
    ZioPower := (StrToIntDef(ParamValue,0)<>0);
    Result := stOk;
  end
{
  else if ParamName='DRIVER_MODE' then
  begin
    n := StrToIntDef(ParamValue,ord(dmSTD));
    if (n>=ord(low(TDriverMode))) and (n<=ord(high(TDriverMode))) then
      DriverMode := TDriverMode(n);
  end
}
end;

procedure SetLanguage(LibName : pchar;Language:pchar;ServiceMode:integer); stdcall;
begin
  LanguageList.InitDllMode(LibName,Language,ServiceMode<>0);
end;


function  GetErrStr(Id :TAccId; Code :TStatus; S : pChar; Max: integer): boolean;  stdcall;
begin
  result := true;
  case Code of
  stOk              : strplcopy(S,Lang.Value(Txt001),Max);
  stTimeErr         : strplcopy(S,Lang.Value(TXT002),Max);
  stUserBreak       : strplcopy(S,Lang.Value(TXT003),Max);
  stTerminate       : strplcopy(S,Lang.Value(TXT004),Max);
  stBadId           : strplcopy(S,Lang.Value(TXT005),Max);
  stNotOpen         : strplcopy(S,Lang.Value(TXT006),Max);

  stAttSemError     : strplcopy(S,Lang.Value(TXT007),Max);
  stMaxAttachCom    : strplcopy(S,Lang.Value(TXT008),Max);
  stSemafErr        : strplcopy(S,Lang.Value(TXT009),Max);
  stCommErr         : strplcopy(S,Lang.Value(TXT010),Max);
  stSetupErr        : strplcopy(S,Lang.Value(TXT011),Max);
  stNoSemafor       : strplcopy(S,Lang.Value(TXT012),Max);
  stBadArguments    : strplcopy(S,Lang.Value(TXT014),Max);

  else
    strplcopy(S,Lang.Value(Txt013)+' '+IntToStr(Code),Max);
    result := false;
  end;
end;

initialization
  IsMultiThread := True;  // Make memory manager thread safe
  GlobDevAcces := TDevAcces.Create;
  EmulateVer := 0;

  Lang := GlobDictionary.AddGroup('ThRsdUnit');

  Lang.AddItem(TXT001,'Ok'                                              );
  Lang.AddItem(TXT002,'Time Out.'                                       );
  Lang.AddItem(TXT003,'Operacja przerwana.'                             );
  Lang.AddItem(TXT004,'zamykanie programu.'                             );
  Lang.AddItem(TXT005,'Nie nawi¹zanie po³¹czenie.'                      );
  Lang.AddItem(TXT006,'Port nie otwarty.'                               );
  Lang.AddItem(TXT007,'Brak dostêpu do portu w trybie wielodostêpowym.' );
  Lang.AddItem(TXT008,'Zbyt du¿o aktywnych u¿ytkowników portu.'         );
  Lang.AddItem(TXT009,'B³¹d trybu wielodostêpowego.'                    );
  Lang.AddItem(TXT010,'B³¹d otwarcia portu.'                            );
  Lang.AddItem(TXT011,'Z³e parametry portu.'                            );
  Lang.AddItem(TXT012,'Brak dostêpu do semafora portu.'                 );
  Lang.AddItem(TXT013,'B³¹d nr '                                        );
  Lang.AddItem(TXT014,'Niew³aœciwy parametr funkcji.'                   );



finalization
  FreeAndNil(GlobDevAcces);
  CountDivide := REC_SIZE;

end.
