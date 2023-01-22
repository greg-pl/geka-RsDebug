unit MdbRsdUnit;

interface

uses
  SysUtils,
  Classes,
  Windows,
  Messages,
  Contnrs,
  WinSock,
  SimpSock,
  MAth;


const
  CommLibGuid   : TGUID ='{FAE45317-98B4-4F99-8682-2C822CDC5196}';
  DEFAULT_PORT  = 502;


  LibPropertyStr : string =
    '<?xml version="1.0" standalone="yes"?>'+
    '<CMM_DESCR>'+
      '<CMM_INFO TYPE="TCP" DESCR="Port TCP (ModbusTCP)" SIGN="MTCP"/>'+
      '<GROUP>'+
        '<ITEM DESCR="IP" TYPE="IP" DEFVALUE="10.20.3.61" />'+
        '<ITEM DESCR="Port TCP" TYPE="INT" MIN="0" MAX="65535" DEFVALUE="512"/>'+
      '</GROUP>'+
    '</CMM_DESCR>';

  evProgress  = 0;
  evFlow      = 1;
  evWorkOnOff = 4;

  stBadRepl         = 17;
  stBadArguments    = 18;
  stMdbError        = 32;



  stBadId           = 18;
  stTimeErr         = 19;
  stBadReplay       = 24;  // z³a odpowiedŸ urz¹dzenia
  stAckTimeErr      = 25;
  stBadHostRepl     = 26;
  stUnkHostFunct    = 27;
  stUnkBeckRepl     = 28;
  stBadParams       = 29;
  stH8Error         = 31;
  stException       = 32;  // w trakcie wykonywania polecenia wyst¹pi³ wyj¹tek
  stBufferToSmall   = 50;  // publiczny - rozpoznawany przez warstwê wy¿sza


type
  TStatus    = integer;
  TAccId     = integer;
  TSesID     = cardinal;
  TFileNr    = byte;
  TByteArray = array of byte;
  TTabBit    = array[0..32768] of boolean;
  TTabWord  = array[0..32768] of word;



  TMBAP = packed record
     TI  : word;
     PI  : word;
     Len : word;
     UI  : byte;
  end;



TCallBackFunc = procedure(Id :TAccId; CmmId : integer; Ev : integer; R : real); stdcall;
TGetMemFunc = function(MemSize : integer): pointer; stdcall;

procedure LibIdentify(var LibGuid :TGUID); stdcall;
function  GetLibProperty:pchar; stdcall;
function  RegisterCallBackFun(Id :TAccId; CmmId : integer; CallBackFunc : TCallBackFunc): TStatus; stdcall;
function  SetBreakFlag(Id :TAccId; Val:boolean): TStatus; stdcall;
procedure SetLanguage(LibName : pchar;Language:pchar;ServiceMode:integer); stdcall;
function  GetDrvStatus(Id :TAccId; ParamName : pchar; ParamValue :pchar; MaxRpl:integer): TStatus; stdcall;
function  SetDrvParam(Id :TAccId; ParamName : pchar; ParamValue :pchar): TStatus; stdcall;

function  AddDev(ConnectStr : pchar): TAccId; stdcall;
function  DelDev(Id :TAccId):TStatus; stdcall;
function  OpenDev(Id :TAccId):TStatus; stdcall;
procedure CloseDev(Id :TAccId); stdcall;
function  GetErrStr(Id :TAccId; Code :TStatus; S : pChar; Max: integer): boolean;  stdcall;

// funkcje podstawowe Modbusa
function  RdOutTable(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
function  RdInpTable(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
function  RdReg(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
function  RdAnalogInp(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
function  WrOutput(Id :TAccId; Adress : word; Val : word):TStatus; stdcall;
function  WrReg(Id :TAccId; Adress : word; Val : word):TStatus; stdcall;
function  WrMultiReg(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
function  RdWrMultiReg(Id :TAccId; var RdBuf; RdAdress : word; RdCount :word;
                        const WrBuf; WrAdress : word; WrCount :word):TStatus; stdcall;




Exports
    LibIdentify,
    GetLibProperty,
    RegisterCallBackFun,
    SetBreakFlag,
    SetLanguage,
    GetDrvStatus,
    SetDrvParam,

    AddDev,
    DelDev,
    OpenDev,
    CloseDev,
    GetErrStr,

    RdOutTable,
    RdInpTable,
    RdReg,
    RdAnalogInp,
    WrOutput,
    WrReg,
    WrMultiReg,
    RdWrMultiReg;



implementation
{$IFDEF INT_LANG}
uses
  iniFiles;
type
  TLang = class;
  TGlobDictionary = class(TMemIniFile)
    constructor Create;
    function AddGroup(SecName : string): TLang;
  end;

  TLanguageList = class(TObject)
    procedure InitDllMode(LibName,Language : string; ServiceMode : boolean);
  end;
  TLang = class(TObject)
     Dict : TGlobDictionary;
     secName : string;
    function Value(key : string): string;
    procedure AddItem(key,val : string);
  end;


var
  GlobDictionary : TGlobDictionary;
  LanguageList : TLanguageList;
  Lang : TLang;


constructor TGlobDictionary.Create;
begin
  inherited Create('');
end;

function TGlobDictionary.AddGroup(SecName : string): TLang;
begin
  Result := TLang.Create;
  Result.secName := SecName;
  Result.Dict := self;
end;


procedure TLanguageList.InitDllMode(LibName,Language : string; ServiceMode : boolean);
begin

end;

function TLang.Value(key : string): string;
begin
  Result :=  Dict.ReadString(secName,key,'');
end;

procedure TLang.AddItem(key,val : string);
begin
  Dict.WriteString(secName,key,val);
end;

{$ELSE}
uses
  LangUnit;
var
  Lang : TXLangGroup;

{$ENDIF}


const
  TXT001 = 'TXT001';
  TXT002 = 'TXT002';
  TXT003 = 'TXT003';
  TXT005 = 'TXT005';
  TXT006 = 'TXT006';
  TXT007 = 'TXT007';
  TXT008 = 'TXT008';
  TXT009 = 'TXT009';
  TXT010 = 'TXT010';
  TXT011 = 'TXT011';
  TXT012 = 'TXT012';
  TXT018 = 'TXT018';
  TXT019 = 'TXT019';
  TXT020 = 'TXT020';
  TXT021 = 'TXT021';
  TXT022 = 'TXT022';
  TXT023 = 'TXT023';
  TXT024 = 'TXT024';
  TXT025 = 'TXT025';

type


TOnProgress   = procedure(Sender: TObject; Pos : real) of object;



TDevice = class(TObject)
  private
    AccID         : integer;
    MyIp          : string;
    mUI           : byte;          // identyfikator w protokole MODBUSTCP
    SmTcp         : TSimpTcp;
    FOnProgress   : TOnProgress;
    FCallBackFunc : TCallBackFunc;
    FCmmId        : integer;
    glProgress    : boolean;       // false -> progress wysy³a procedura Konwers
    glToReadCnt   : integer;
    glReadSuma    : integer;
    BreakFlag     : boolean;
    FAskNr        : word;
    SafetySection : TRTLCriticalSection;
    TransacId     : word;
    FMdbStdCndDiv : integer;      // podzia³ na krótsze ramki dla standardowych zapytañ MODBUS


    //    function   CheckSuma(const Header:TNetQuery;  const Buf; Len:integer): boolean;
    function   RecivAnswer(var BtArr : TByteArray): TStatus;


    function  Konwers(AskBuf : TByteArray; var RplFrame : TByteArray): TStatus;
    procedure SetWord(buf : TByteArray; ofs: integer; val : word);
    function  RdWordsUniHd(Fun : byte; var QA : TByteArray; Adress : word; Count :word):TStatus;
    function  RdWordsUni(Fun : byte; var Buf; Adress : word; Count :word):TStatus;
    function  RdBitsUni(Fun : byte; var Buf; Adress : word; Count :word):TStatus;
    function  WrMultiRegHd(Adress : word; Count :word; pW: pWord):Tstatus;
    function  RdWrMultiRegHd(RdAdress : word; RdCount :word; var QA : TByteArray;
                             WrAdress : word; WrCount :word; pWWr: pWord):Tstatus;
    function   CheckOpen: TStatus;
  protected
    procedure  MsgRdFlowSize(Sender :TObject;R: real);
    procedure  GoBackFunct(Ev: integer; R: real);
    procedure  SetProgress(F: real); overload;
    procedure  SetProgress(Cnt,Max:integer); overload;
    procedure  SetWorkFlag(w : boolean);
    procedure  MsgFlowSize(R: real);

  public
    LastOkTransm : Cardinal;  // czas ostatniej poprawnej ramki
    constructor Create(AIp : string; APort : word; aUI : byte);
    destructor Destroy; override;

    function   Open : TStatus;
    function   Close : TStatus;
    function   SetBreakFlag(Val : boolean):integer;
    property   OnProgress : TOnProgress read FOnProgress write FOnProgress;
    procedure  RegisterCallBackFun(ACallBackFunc : TCallBackFunc; CmmId : integer);
    function   GetDrvStatus(ParamName : pchar; ParamValue :pchar; MaxRpl:integer): TStatus;
    function   SetDrvParam(ParamName : pchar; ParamValue :pchar): TStatus;

    // funkcje podstawowe Modbusa
    function    RdOutTable(var Buf; Adress : word; Count :word):TStatus;
    function    RdInpTable(var Buf; Adress : word; Count :word):TStatus;
    function    RdReg(var Buf; Adress : word; Count :word):TStatus;
    function    RdAnalogInp(var Buf; Adress : word; Count :word):TStatus;
    function    WrOutput(Adress : word; Val : boolean):TStatus;
    function    RdStatus(var Val : byte):TStatus;
    function    WrReg(Adress : word; Val : word):TStatus;
    function    WrMultiReg(var Buf; Adress : word; Count :word):TStatus;
    function    RdWrMultiReg(var RdBuf; RdAdress : word; RdCount :word;
                             const WrBuf; WrAdress : word; WrCount :word):TStatus;
  end;


  TDevList = class(TList)
  private
    FCurrId     : TAccId;
    FCriSection : TRTLCriticalSection;
    function  GetItem(Index:integer):TDevice;
    function  GetTocken(s : pChar; var p: integer):shortstring;
    function  GetId:TAccId;
  public
    constructor Create;
    destructor  Destroy; override;
    property  Items[Index: integer]: TDevice read GetItem;
    function  AddAcc(ConnectStr : pchar): TAccId;
    function  DelAcc(AccId : TAccId):TStatus;
    function  FindId(AccId : TAccId):TDevice;
  end;


var
  GlobDevList : TDevList;

const
  stEND_OFF_DIR     = -25;
  MAX_MDB_FRAME_SIZE = 240;
  MAX_MDB_STD_FRAME_SIZE = 112;




function DSwap(X : Cardinal):cardinal;
begin
  Result := Swap(X shr 16) or (Swap(x and $ffff) shl 16);
end;


//-------------------- TDevice ----------------------------------------------
const
  REQ_TSHB     = $10;
  REQ_OWN      = $11;
  REQ_CTRL     = $12;
  REQ_H8       = $13;

  MAX_SENS_SIZE = 32*1024; //32kB

constructor TDevice.Create(AIp : string; APort : word; aUI : byte);
begin
  inherited Create;
  InitializeCriticalSection(SafetySection);
  SmTcp := TSimpTcp.Create;
  SmTcp.Ip := AIp;
  SMTcp.Port := APort;
  mUI := aUI;
  FCallBackFunc := nil;
  FAskNr := 0;
  FMdbStdCndDiv := MAX_MDB_STD_FRAME_SIZE;
  TransacId := 0;
end;

destructor TDevice.Destroy;
begin
  FreeAndNil(SmTcp);
  DeleteCriticalSection(SafetySection);

  inherited;
end;


function TDevice.Open : TStatus;
begin
  SmTcp.RecWaitTime := 1000; // !!!! nie zmieniaæ po wykoananiu open
  Result := SmTcp.Open;
  if Result=stOk then
    Result := SmTcp.Connect;
  LastOkTransm := GetTickCount;
end;

function TDevice.Close : TStatus;
begin
  Result := SmTcp.Close;
end;

function TDevice.GetDrvStatus(ParamName : pchar; ParamValue :pchar; MaxRpl:integer): TStatus;
begin
  Result := stBadParams;
end;

function  TDevice.SetDrvParam(ParamName : pchar; ParamValue :pchar): TStatus;
begin
  //Result := stOk;
  Result := stBadParams;
end;


function TDevice.SetBreakFlag(Val : boolean):integer;
begin
  BreakFlag := val;
  SmTcp.SetBreak(val);
  Result := stok;
end;

function TDevice.CheckOpen: TStatus;
begin
  Result :=stOk;
  if SmTcp.Socket = INVALID_SOCKET then
    Result :=stNotOpen;
end;

procedure  TDevice.GoBackFunct(Ev: integer; R: real);
begin
  if Assigned(FCallBackFunc) then
    FCallBackFunc(AccID,FCmmId,Ev,R);
end;

procedure TDevice.SetProgress(F: real);
begin
  GoBackFunct(evProgress,F);
end;

procedure  TDevice.SetProgress(Cnt,Max:integer);
Var
  R : real;
begin
  if Max<>0 then
    R := 100*(Cnt/max)
  else
    R:=100;
  SetProgress(R);
end;

procedure TDevice.SetWorkFlag(w : boolean);
begin
  if w then
    GoBackFunct(evWorkOnOff,1)
  else
    GoBackFunct(evWorkOnOff,0);
end;


procedure TDevice.MsgFlowSize(R: real);
begin
  GoBackFunct(evFlow,R);
end;


// callbeck z SimpSocket
procedure TDevice.MsgRdFlowSize(Sender :TObject;R: real);
begin
  MsgFlowSize(R+glReadSuma);
  if glToReadCnt<>0 then
    R := 100*(R+glReadSuma)/glToReadCnt
  else
    R := 100;
  SetProgress(R);
end;

type
  TMyMemoryStream =Class(Classes.TMemoryStream)
  private
  protected
  public
  end;


function  TDevice.RecivAnswer(var BtArr : TByteArray): TStatus;
var
  L        : integer;
  T        : cardinal;
  aTmap    : TMBAP;
begin
  SmTcp.RecWaitTime := 500; // czas na odpowiedŸ
  T := GetTickCount;
  Result := SmTcp.ReciveToBufTime(T,aTmap,Sizeof(aTmap));           if Result<>stOk then Exit;
  L := Swap(aTmap.Len)-1;
  setLength(BtArr,L);
  Result := SmTcp.ReciveToBufTime(T,BtArr[0],L);                    if Result<>stOk then Exit;
end;

const
  tkOK          = 0;
  tkNoAck       = 1;
  tkNoRepl      = 2;
  tkReplCodeErr = 3;
  tkUnkFunc     = 4;
  tkReplDtErr   = 5;
  tkNO_SMF      = 6;
  tkH8Error     = 8;
  tkBadParams   = 5;




function  TDevice.Konwers(AskBuf : TByteArray; var RplFrame : TByteArray): TStatus;
var
  AskCnt    : integer;
  Rep       : integer;
  AskFrame  : TByteArray;
  aTmap     : TMBAP;
begin
  Result:=CheckOpen;
  if Result<>stOk then Exit;
  if not(glProgress) then
    SetProgress(0);
  SetWorkFlag(true);

  AskCnt := length(AskBuf);
  inc(TransacId);
  aTmap.TI := TransacId;
  aTmap.PI := 0;
  aTmap.Len := Swap(AskCnt+1);
  aTmap.UI := mUI;


  SetLength(AskFrame,sizeof(TMBAP)+AskCnt);
  Move(aTmap,Askframe[0],sizeof(aTmap));
  Move(AskBuf[0],Askframe[sizeof(aTmap)],AskCnt);


  Rep:=0;
  while Rep<2 do
  begin
    inc(Rep);
    Result := SmTcp.ClearInpBuf;
    if Result=stOk then
      Result := SmTcp.Write(AskFrame[0],length(AskFrame));
    if Result=stOk then
      Result := RecivAnswer(Rplframe);
    if Result=stOk then
      break;
  end;

  if Result=stOk then
  begin
    if not(glProgress) then
      SetProgress(100);
    LastOkTransm := GetTickCount;
  end;
  SetWorkFlag(false);
end;


procedure TDevice.RegisterCallBackFun(ACallBackFunc : TCallBackFunc; CmmId : integer);
begin
  FCallBackFunc := ACallBackFunc;
  FCmmId := CmmId;
end;

procedure TDevice.SetWord(buf : TByteArray; ofs: integer; val : word);
begin
  buf[ofs+0]:=byte(val shr 8);
  buf[ofs+1]:=byte(val and $ff);
end;

function  TDevice.RdBitsUni(Fun : byte; var Buf; Adress : word; Count :word):TStatus;
var
  Q   : TByteArray;
  QA  : TByteArray;
  i        : integer;
  b        : byte;
  mask     : byte;
begin
  SetLength(Q,5);
  Q[0]:=Fun;
  SetWord(Q,1,Adress);
  SetWord(Q,3,Count);
  Result := Konwers(Q,QA);
  if Result=stOk then
  begin
    if QA[0]=Fun then
    begin
      for i:=0 to Count-1 do
      begin
        b := QA[2+(i div 8)];
        mask := $01 shl (i mod 8);
        TTabBit(Buf)[i]:= ((b and mask)<>0);
      end;
    end
    else if QA[0]=(Q[0] or $80) then
       Result := stMdbError + QA[1]
    else
      Result := stBadRepl;
  end;
end;

function TDevice.RdOutTable(var Buf; Adress : word; Count :word):TStatus;
begin
  result := RdBitsUni(1,Buf,Adress,Count);
end;
function TDevice.RdInpTable(var Buf; Adress : word; Count :word):TStatus;
begin
  result := RdBitsUni(2,Buf,Adress,Count);
end;


function  TDevice.RdWordsUniHd(Fun : byte; var QA : TByteArray; Adress : word; Count :word):TStatus;
var
  Q :  TByteArray;
begin
  if Adress>0 then
  begin
    Dec(Adress);
    setlength(q,5);
    Q[0]:=Fun;
    SetWord(Q,1,Adress);
    SetWord(Q,3,Count);
    Result:=Konwers(Q,QA);
    if Result=stOk then
    begin
      if QA[0]=Q[0] then
         Result := stOK
      else if QA[0]=(Q[0] or $80) then
         Result := stMdbError + QA[1]
      else
        Result := stBadRepl;
    end;
  end
  else
    Result := stBadArguments;
end;

function TDevice.RdWordsUni(Fun : byte; var Buf; Adress : word; Count :word):TStatus;
var
  Cnt    : word;
  QA     : TByteArray;
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
    st := RdWordsUniHd(Fun,QA,Adress,Cnt);
    if st=stOk then
    begin
      for i:=0 to Cnt-1 do
      begin
         w := QA[2*i+2]*256+QA[2*i+3];
         TTabWord(Buf)[N]:=w;
         inc(N);
      end;
    end;

    Adress := Adress+Cnt;
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

function TDevice.RdReg(var Buf; Adress : word; Count :word):TStatus;
begin
  Result := RdWordsUni(3,Buf,Adress,Count);
end;

function TDevice.RdAnalogInp(var Buf; Adress : word; Count :word):TStatus;
begin
  Result := RdWordsUni(4,Buf,Adress,Count);
end;


function TDevice.WrOutput(Adress : word; Val : boolean):TStatus;
var
  Q      : TByteArray;
  QA     : TByteArray;
begin
  Dec(Adress);
  Setlength(Q,5);
  Q[0]:=$05;
  SetWord(Q,1,Adress);
  if Val then  Q[3]:=$FF
         else  Q[3]:=$00;
  Q[4]:=$00;
  Result:=Konwers(Q,QA);
  if Result=stOk then
  begin
    if QA[0]=(Q[0] or $80) then
       Result := stMdbError + QA[1]
    else if (q[0]<>qa[0]) or (q[3]<>qa[3]) or (q[4]<>qa[4]) then
      Result := stBadRepl;
  end;
end;


function TDevice.RdStatus(var Val : byte):TStatus;
var
  Q  : TByteArray;
  QA : TByteArray;
begin
  SetLength(Q,1);
  Q[0]:=$07;
  Result:=Konwers(Q,QA);
  if Result=stOk then
    if QA[0]<>Q[0] then
      Result := stBadRepl;
  if Result=stOk then
    Val := QA[1];
end;


function TDevice.WrReg(Adress : word; Val : word):TStatus;
var
  Q  : TByteArray;
  QA : TByteArray;
begin
  Dec(Adress);
  Setlength(Q,5);
  Q[0]:=$06;
  SetWord(Q,1,Adress);
  SetWord(Q,3,Val);
  Result:=Konwers(Q,QA);
  if Result=stOk then
  begin
    if (QA[0]=Q[0]) and (QA[1]=Q[1]) and (QA[2]=Q[2]) and (QA[3]=Q[3]) and (QA[4]=Q[4]) then
       Result := stOK
    else if QA[0]=(Q[0] or $80) then
       Result := stMdbError + QA[1]
    else
      Result := stBadRepl;
  end;
end;

function TDevice.WrMultiRegHd(Adress : word; Count :word; pW: pWord):Tstatus;
var
  Q    :  TByteArray;
  QA   :  TByteArray;
  w    :  word;
  i    : integer;
  rCnt : word;
  rAdr : word;
begin
  Dec(Adress);
  SetLength(Q,6+2*Count);
  Q[0]:=16;
  SetWord(Q,1,Adress);
  SetWord(Q,3,Count);
  Q[5]:= 2*Count;
  for i:=0 to Count-1 do
  begin
    w := pw^;
    inc(pw);
    Q[6+i*2+0]:= byte(w shr 8);
    Q[6+i*2+1]:= byte(w);
  end;
  Result:=Konwers(Q,QA);
  if Result=stOK then
  begin
    if QA[0]=Q[0] then
    begin
      rAdr := QA[1]*256+QA[2];
      rCnt := QA[3]*256+QA[4];
      if (rCnt=Count) and (rAdr=Adress) then
        Result := stOK
      else
        Result := stBadRepl;
    end
    else if QA[0]=(Q[0] or $80) then
       Result := stMdbError + QA[1]
    else
      Result := stBadRepl;
  end;
end;

function TDevice.WrMultiReg(var Buf; Adress : word; Count :word):TStatus;
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
    inc(Adress,Cnt);
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

function TDevice.RdWrMultiRegHd(RdAdress : word; RdCount :word; var QA : TByteArray;
                              WrAdress : word; WrCount :word; pWWr: pWord):Tstatus;

var
  Q    :  TByteArray;
  w    :  word;
  i    : integer;
begin
  Dec(RdAdress);
  Dec(WrAdress);

  SetLength(Q,10+2*WrCount);
  Q[0]:=$17;
  SetWord(Q,1,RdAdress);
  SetWord(Q,3,RdCount);
  SetWord(Q,5,WrAdress);
  SetWord(Q,7,WrCount);
  Q[9]:= 2*WrCount;
  for i:=0 to WrCount-1 do
  begin
    w := pWwr^;
    inc(pWwr);
    Q[10+i*2+0]:= byte(w shr 8);
    Q[10+i*2+1]:= byte(w);
  end;
  Result:=Konwers(Q,QA);
  if Result=stOK then
  begin
    if (length(QA)=2) and ( QA[0]=(Q[0] or $80)) then
    begin
      Result := stMdbError + QA[1];
    end
    else if (length(QA)= 2*RdCount+2) and (QA[0]=Q[0]) and (QA[1]=2*RdCount) then
    begin
      Result := stOk;
    end
    else
      Result := stBadRepl;
  end;
end;

function  TDevice.RdWrMultiReg(var RdBuf; RdAdress : word; RdCount :word;
                             const WrBuf; WrAdress : word; WrCount :word):TStatus;

var
  RdCnt : word;
  WrCnt : word;
  st    : TStatus;
  pwRd  : pWord;
  pwWr  : pWord;
  SCnt  : integer;
  QA   :  TByteArray;
  i    : integer;
begin
  glProgress := true;
  SetProgress(0);
  MsgFlowSize(0);
  SetWorkFlag(true);

  st := stOk;
  pwRd := pWord(@RdBuf);
  pwWr := pWord(@WrBuf);
  SCnt:=0;
  while ((RdCount<>0) or (WrCount<>0)) and (st=stOk) do
  begin
    RdCnt:=RdCount;
    if RdCnt>FMdbStdCndDiv then
      RdCnt := FMdbStdCndDiv;
    WrCnt:=WrCount;
    if WrCnt>FMdbStdCndDiv then
      WrCnt := FMdbStdCndDiv;

    st := RdWrMultiRegHd(RdAdress,RdCnt,QA,WrAdress,wrCnt,pwWr);
    if st=stOK then
    begin
      try
        for i:=0 to RdCnt-1 do
        begin
           pwRd^ := QA[2*i+2]*256+QA[2*i+3];
           inc(pwRd);
        end;
      except
        st := stException;
      end;
    end;

    inc(pwRd,RdCnt);
    inc(RdAdress,RdCnt);
    dec(RdCount,RdCnt);

    inc(pwWr,WrCnt);
    inc(WrAdress,WrCnt);
    dec(WrCount,WrCnt);

    inc(SCnt,Max(rdCnt,wrCnt));
    SetProgress(SCnt,Max(RdCount,WrCount));
    MsgFlowSize(SCnt);
  end;

  SetProgress(100);
  MsgFlowSize(Max(RdCount,WrCount));
  SetWorkFlag(false);
  glProgress := false;

  Result := st;
end;

//---------------------  TDevList ---------------------------
constructor TDevList.Create;
begin
  inherited Create;
  FCurrId := TAccId(1*1024);
  InitializeCriticalSection(FCriSection);
end;

destructor  TDevList.Destroy;
begin
  DeleteCriticalSection(FCriSection);
  inherited;
end;

function  TDevList.GetItem(Index:integer):TDevice;
begin
  Result := TDevice(inherited Items[Index]); 
end;

function TDevList.GetTocken(s : pChar; var p: integer):shortstring;
begin
  Result :='';
  while (s[p]<>';') and (s[p]<>#0) and (p<=length(s)) do
  begin
    Result := Result+s[p];
    inc(p);
  end;
  inc(p);
end;

function TDevList.GetId:TAccId;
begin
  Result := FCurrId;
  inc(FCurrId);
end;

//  MTCP;192.168.0.125;512;
function TDevList.AddAcc(ConnectStr : pchar): TAccId;
var
  s     : shortstring;
  p     : integer;
  OkStr : boolean;
  DevItem : TDevice;
  Ip      : string;
  port    : word;
  ui      : byte;
begin
  Result := -1;
  p := 0;
  s := GetTocken(ConnectStr,p);
  if s='MTCP' then
  begin
    Ip := GetTocken(ConnectStr,p);
    OkStr := true;
    //OkStr := (StrToInetAdr(Ip,IpD) = stOk);

    s := GetTocken(ConnectStr,p);
    if s<>'' then
    begin
      try
        Port:=StrToInt(s);
      except
        Port:=0;
        OkStr := False;
      end;
    end
    else
      Port := DEFAULT_PORT;

    s := GetTocken(ConnectStr,p);
    if s<>'' then
    begin
      try
        ui:=StrToInt(s);
      except
        UI:=0;
        OkStr := False;
      end;
    end
    else
      UI:=1; //domyœlnie 1



    if OkStr then
    begin
      try
        EnterCriticalSection(FCriSection);
        Devitem := TDevice.Create(Ip,Port,UI);
        DevItem.AccID := GetId;
        DevItem.MyIp := Ip;

        Add(DevItem);
        Result := DevItem.AccID;
      finally
        LeaveCriticalSection(FCriSection);
      end;
    end
  end;
end;

function TDevList.DelAcc(AccId : TAccId):TStatus;
var
  i : integer;
  T : TDevice;
begin
  Result := stBadId;
  try
    EnterCriticalSection(FCriSection);
    for i:=0 to Count-1 do
    begin
      T := TDevice(Items[i]);
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

function TDevList.FindId(AccId : TAccId):TDevice;
var
  i : integer;
begin
  Result := nil;
  if AccId>=0 then
  begin
    try
      EnterCriticalSection(FCriSection);
      for i:=0 to Count-1 do
      begin
        if AccId=Items[i].AccID then
        begin
          Result := Items[i];
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


procedure SetLanguage(LibName : pchar;Language:pchar;ServiceMode:integer); stdcall;
begin
  LanguageList.InitDllMode(LibName,Language,ServiceMode<>0);
end;

function  GetLibProperty:pchar; stdcall;
begin
  result := pchar(LibPropertyStr);
end;

function AddDev(ConnectStr : pchar): TAccId; stdcall;
begin
  Result := GlobDevList.AddAcc(ConnectStr);
end;

function DelDev(Id :TAccId):TStatus; stdcall;
begin
  Result := GlobDevList.DelAcc(Id);
end;

function  GetDrvStatus(Id :TAccId; ParamName : pchar; ParamValue :pchar; MaxRpl:integer): TStatus; stdcall;
var
  Dev : TDevice;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
    Result := Dev.GetDrvStatus(ParamName,ParamValue,MaxRpl)
  else
    Result := stBadId;
end;

function  SetDrvParam(Id :TAccId; ParamName : pchar; ParamValue :pchar): TStatus; stdcall;
var
  Dev : TDevice;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
    Result := Dev.SetDrvParam(ParamName,ParamValue)
  else
    Result := stBadId;
end;

function OpenDev(Id :TAccId):TStatus; stdcall;
var
  Dev     : TDevice;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
    Result := Dev.Open
  else
    Result := stBadId;
end;

procedure  CloseDev(Id :TAccId); stdcall;
var
  Dev     : TDevice;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
  begin
    Dev.Close;
  end;
end;

function  RegisterCallBackFun(Id :TAccId; CmmId : integer; CallBackFunc : TCallBackFunc): TStatus; stdcall;
var
  Dev : TDevice;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
  begin
    Dev.RegisterCallBackFun(CallBackFunc,CmmId);
    Result := stOk;
  end
  else
    Result := stBadId;
end;

function  SetBreakFlag(Id :TAccId; Val:boolean): TStatus; stdcall;
var
  Dev : TDevice;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
    Result := Dev.SetBreakFlag(Val)
  else
    Result := stBadId;
end;

// Funkcje standardowe Modbus
function  RdOutTable(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
var
  Dev : TDevice;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.RdOutTable(Buf,Adress,Count);
  end
  else
    Result := stBadId;
end;

function  RdInpTable(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
var
  Dev : TDevice;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.RdInpTable(Buf,Adress,Count);
  end
  else
    Result := stBadId;
end;

function  RdReg(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
var
  Dev : TDevice;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.RdReg(Buf,Adress,Count);
  end
  else
    Result := stBadId;
end;

function  RdAnalogInp(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
var
  Dev : TDevice;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.RdAnalogInp(Buf,Adress,Count);
  end
  else
    Result := stBadId;
end;

function  WrOutput(Id :TAccId; Adress : word; Val : word):TStatus; stdcall;
var
  Dev : TDevice;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.WrOutput(Adress,Val<>0);
  end
  else
    Result := stBadId;
end;

function  WrReg(Id :TAccId; Adress : word; Val : word):TStatus; stdcall;
var
  Dev : TDevice;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.WrReg(Adress,Val);
  end
  else
    Result := stBadId;
end;

function  WrMultiReg(Id :TAccId; var Buf; Adress : word; Count :word):TStatus; stdcall;
var
  Dev : TDevice;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.WrMultiReg(Buf,Adress,Count);
  end
  else
    Result := stBadId;
end;

function  RdWrMultiReg(Id :TAccId; var RdBuf; RdAdress : word; RdCount :word;
                        const WrBuf; WrAdress : word; WrCount :word):TStatus; stdcall;
var
  Dev : TDevice;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
  begin
    Result := Dev.RdWrMultiReg(RdBuf,RdAdress,RdCount,WrBuf,WrAdress,WrCount);
  end
  else
    Result := stBadId;
end;



function  GetErrStr(Id :TAccId; Code :TStatus; S : pChar; Max: integer): boolean;  stdcall;
begin
  result := true;
  case Code of
  stOk              : strplcopy(S,Lang.Value(Txt001),Max);
  WSAETIMEDOUT,
  stTimeErr         : strplcopy(S,Lang.Value(TXT002),Max);
  stUserBreak       : strplcopy(S,Lang.Value(TXT003),Max);
  stBadId           : strplcopy(S,Lang.Value(TXT005),Max);
  stNotOpen         : strplcopy(S,Lang.Value(TXT006),Max);
  stAckTimeErr      : strplcopy(S,Lang.Value(TXT019),Max);
  stBadParams       : strplcopy(S,Lang.Value(TXT023),Max);

  stBadReplay,
  stBadHostRepl,
  stUnkHostFunct,
  stUnkBeckRepl     : strplcopy(S,Format('%s (%u)',[Lang.Value(TXT009),Code]),Max);

  WSAECONNRESET     : strplcopy(S,Lang.Value(TXT011),Max);
  WSAENOTCONN       : strplcopy(S,Lang.Value(TXT012),Max);
  WSAECONNABORTED   : strplcopy(S,Lang.Value(TXT024),Max);

  else
    result := false;
    if (Code>=stMdbError) and (Code<stMdbError+40 {??}) then
    begin
      strplcopy(S,Format('B³¹d protoko³u MODBUS :%u',[Code-stMdbError]),Max);
      Result := true;
    end;
  end;
  if not(result) then
  begin
    strplcopy(S,Lang.Value(Txt018)+' '+IntToStr(Code),Max);
  end;
end;



initialization
  IsMultiThread := True;  // Make memory manager thread safe
  GlobDevList := TDevList.Create;

{$IFDEF INT_LANG}

  GlobDictionary := TGlobDictionary.Create;
  LanguageList := TLanguageList.Create;

{$ENDIF}


  Lang := GlobDictionary.AddGroup('TcpRsdUnit');

  Lang.AddItem(TXT001,'Ok'                                              );
  Lang.AddItem(TXT002,'Time Out.'                                       );
  Lang.AddItem(TXT003,'Operacja przerwana.'                             );
  Lang.AddItem(TXT005,'Nie nawi¹zanie po³¹czenie.'                      );
  Lang.AddItem(TXT006,'Port nie otwarty.'                               );
  Lang.AddItem(TXT007,'B³¹d sumy kontrolnej nag³ówka.'                  );
  Lang.AddItem(TXT008,'B³¹d sumy kontrolnej bufora danych.'             );
  Lang.AddItem(TXT011,'Po³¹czenie zamkniête przez zdalnego hosta'       );
  Lang.AddItem(TXT012,'Po³¹czenie nie nawi¹zane.'                       );
  Lang.AddItem(TXT018,'B³¹d nr '                                        );
  Lang.AddItem(TXT019,'Time Out.(Ack)'                                  );
  Lang.AddItem(TXT023,'Niepoprawny paramter zapytania');
  Lang.AddItem(TXT024,'Zerwane po³¹czenie');
  Lang.AddItem(TXT025,'Brak pamiêci');
  Lang.AddItem(TXT009,'B³¹d komunikacji' );

finalization
  GlobDevList.Free;


end.
