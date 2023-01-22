unit TcpRsdUnit;

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
  DEFAULT_PORT  = 8040;
{
  LibPropertyStr : string =
    '<?xml version="1.0" standalone="yes"?>'+
    '<LIB_DESCR>'+
      '<INFO TYPE="TCP" DESCR="£¹cze TCP (protokó³ RSD)" SIGN="RTCP"/>'+
      '<PARAMS>'+
        '<PARAM DESCR="IP" TYPE="IP" DEFAULT="10.20.3.61" />'+
        '<PARAM DESCR="Port TCP" TYPE="WORD" DEFAULT="8040"/>'+
      '</PARAMS>'+
    '</LIB_DESCR>';

  LibPropertyStrV2 : string =
    '<?xml version="1.0" standalone="yes"?>'+
    '<CMM_DESCR>'+
      '<CMM_INFO TYPE="TCP" DESCR="£¹cze TCP (protokó³ RSD)" SIGN="RTCP"/>'+
      '<GROUP>'+
        '<ITEM DESCR="IP" TYPE="IP" DEFVALUE="10.20.3.61" />'+
        '<ITEM DESCR="Port TCP" TYPE="INT" MIN="0" MAX="65535" DEFVALUE="8040"/>'+
      '</GROUP>'+
    '</CMM_DESCR>';
}

  LibPropertyStr : string =
    '<?xml version="1.0" standalone="yes"?>'+
    '<LIB_DESCR>'+
      '<INFO TYPE="TCP" DESCR="Port TCP (protocol RSD)" SIGN="RTCP"/>'+
      '<PARAMS>'+
        '<PARAM DESCR="IP" TYPE="IP" DEFAULT="10.20.3.61" />'+
        '<PARAM DESCR="Port TCP" TYPE="WORD" DEFAULT="8040"/>'+
      '</PARAMS>'+
    '</LIB_DESCR>';

  LibPropertyStrV2 : string =
    '<?xml version="1.0" standalone="yes"?>'+
    '<CMM_DESCR>'+
      '<CMM_INFO TYPE="TCP" DESCR="Port TCP (protocol RSD)" SIGN="RTCP"/>'+
      '<GROUP>'+
        '<ITEM DESCR="IP" TYPE="IP" DEFVALUE="10.20.3.61" />'+
        '<ITEM DESCR="Port TCP" TYPE="INT" MIN="0" MAX="65535" DEFVALUE="8040"/>'+
      '</GROUP>'+
    '</CMM_DESCR>';

  evProgress  = 0;
  evFlow      = 1;
  evWorkOnOff = 4;

  stBadId           = 18;
  stTimeErr         = 19;
  stTooMuchRecData  = 20;
  stSumHeaderError  = 21;
  stSumBufError     = 22;
  stBadReplay       = 24;  // z³a odpowiedŸ urz¹dzenia
  stAckTimeErr      = 25;
  stBadHostRepl     = 26;
  stUnkHostFunct    = 27;
  stUnkBeckRepl     = 28;
  stBadParams       = 29;
  stNoMemory        = 30;
  stH8Error         = 31;
  stException       = 32;  // w trakcie wykonywania polecenia wyst¹pi³ wyj¹tek
  stBufferToSmall   = 50;  // publiczny - rozpoznawany przez warstwê wy¿sza




  // b³ady zwracane przez obs³ugê sesji w H8
{
  stHwBase          = -100;
  stHwUnknownCommand= -(-stHwBase+0);
  stHwBadFileNr     = -(-stHwBase+1);
  stHwBadSesionID   = -(-stHwBase+2);
  stHwNoFreeSesFile = -(-stHwBase+3);
  stHwNoFreeSes     = -(-stHwBase+4);
}


type
  TStatus   = integer;
  TAccId    = integer;
  TSesID    = cardinal;
  TFileNr   = byte;
  TSeGuid   = record
                d1 : cardinal;
                d2 : cardinal;
              end;

STR16 = array[0..15] of char;

TDevInfo = packed record
   DevName : STR16;
   DspDataBase : cardinal;
   DspDataSize : cardinal;
   DspProgBase : cardinal;
   DspProgSize : cardinal;
end;
              

TCallBackFunc = procedure(Id :TAccId; CmmId : integer; Ev : integer; R : real); stdcall;
TGetMemFunc = function(MemSize : integer): pointer; stdcall;

procedure LibIdentify(var LibGuid :TGUID); stdcall;
procedure SetEmulateVer(Ver : integer); stdcall;
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

function  ReadS(Id :TAccId; var S; var Vec : Cardinal): TStatus; stdcall;
function  ReadDevInfo(Id :TAccId; var DevInfo :TDevInfo): TStatus; stdcall;
function  ReadReg(Id :TAccId; var  Buffer): TStatus; stdcall;
function  ReadMem(Id :TAccId; var Buffer; adr : Cardinal; size : Cardinal): TStatus; stdcall;
function  WriteMem(Id :TAccId; var Buffer; adr : Cardinal; Size : Cardinal): TStatus; stdcall;
function  WriteCtrl(Id :TAccId; nr: byte; b: byte): TStatus; stdcall;
function  ReadCtrl(Id :TAccId; nr : byte; var b : byte): TStatus; stdcall;
function  OwnKonwers(Id :TAccId; var Header; var Buffer; var SizeR: integer; SizeW : integer): TStatus; stdcall;

// dostep do sesji i plików

function  SeOpenSesion(Id :TAccId; var SesId : TSesID) : TStatus; stdcall;
function  SeCloseSesion(Id :TAccId; SesId : TSesID) : TStatus; stdcall;
function  SeOpenFile(Id :TAccId; SesId : TSesID; FName : pchar; Mode : byte; var FileNr : TFileNr):TStatus; stdcall;
function  SeGetDir(Id :TAccId; SesId : TSesID; FName : pchar; Attrib : byte; Buffer : pchar; MaxLen : integer):TStatus; stdcall;
function  SeGetDir2(Id :TAccId; SesId : TSesID; FName : pchar; Attrib : byte; var Buffer : pchar; GetMemFunc : TGetMemFunc):TStatus; stdcall;

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
    SetBreakFlag,
    SetLanguage,
    GetDrvStatus,
    SetDrvParam,

    AddDev,
    DelDev,
    OpenDev,
    CloseDev,
    GetErrStr,

    ReadS,
    ReadDevInfo,
    ReadReg,
    ReadMem,
    WriteMem,
    WriteCtrl,
    ReadCtrl,
    OwnKonwers,

    SeOpenSesion,
    SeCloseSesion,
    SeOpenFile,
    SeGetDir,
    SeGetDir2,
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
  TXT026 = 'TXT026';


type

{$A-}

TBody = packed record    // 16 bajtów
  case integer of
  0 : (Buf    : array[0..15] of byte;);
  1 : (QrCmd     : char;
       VarB      : byte;
       VarB2     : byte;
       BeckSesNr : byte;    // tutaj BECK wpisuje numer sesji dla H8
       Adr1      : Cardinal;
       Adr2      : Cardinal;
       Size      : Cardinal;);
  2 : (Free      : Cardinal;
       DevName   : array[0..4] of char;
       DevVec    : Cardinal;);
  4 : (bb        : array[0..1] of byte;
       VarW      : smallint;
       ErrCode   : smallint);
end;

  FSTR160 = array[0..159] of char;
  FSTR236 = array[0..235] of char;
  BUF235  = array[0..234] of char;

TSEAskFrame = packed record
  AskCnt   : word;
  SesionID : cardinal;
  case integer of
  0 : (FileNr   : byte;     //Write
       Buf      : BUF235;);
  1 : (Command  : FSTR236;);
  2 : (FileNr1  : byte;     // seek,readfile
       BArg1    : byte;
       Arg1     : cardinal;);
  3 : (OpenMode : byte;     // Open File
       Free     : byte;
       FName    : FSTR160;);
  4 : (FileNr2  : byte;     // Get Error Code
       Free2    : byte;
       ErrCode  : word;);
  5 : (First    : byte;     // GetDirs
       Attrib   : byte;
       Mode     : byte;
       Free3    : byte;
       Path     : FSTR160;);
  6 : (AutoClose  : byte;
       SizeToRead : byte;
       FName2     : FSTR160;);
  end;

TBeckSoftVer = (bVer1,bVer2,bVer3);

TNetQuery = packed object
    Body        : TBody;
    AskFrame    : TSEAskFrame;
    AskFrameCnt : integer;
    procedure Finish;
    procedure Init; overload;
    procedure Init(SesId : TSesID; AskC : word); overload;
    procedure GetProtokolVersion;
    procedure SetEmulateVer(BeckSoftVer : TBeckSoftVer);
    procedure ReadS;
    procedure ReadDevInfo;
    procedure ReadM(adr : Cardinal; aSize : integer);
    procedure WriteM(adr : Cardinal; aSize : integer);
    procedure ReadReg;
    procedure ReadCtrl(ANr : byte);
    procedure WriteCtrl(ANr: byte; AVal: byte);
    function  GetName: string;
    function  GetTabVec: Cardinal;
    // obs³uga plików
    procedure GetErrStr(Code :TStatus);
    procedure SeOpenSesion(AplName : string);
    procedure SeCloseSesion(SesId : TSesID; AskC : word);
    procedure SeOpenFile(SesId : TSesID; AskC : word; FName : pchar; Mode : byte);
    procedure SeGetDir(SesId : TSesID; AskC : word;  First :boolean; APath : pchar; Attrib : byte);
    procedure SeGetDrvList(SesId : TSesID; AskC : word);
    procedure SeShell(SesId : TSesID; AskC : word; Command : pchar);
    procedure SeGetGuidEx(SesId : TSesID; AskC : word; FName : pchar);
    procedure SeReadFileEx(SesId : TSesID; AskC : word; FName : pchar; AutoClose: boolean; Size : byte);

    procedure SeReadFile(SesId : TSesID; AskC : word; FileNr : TFileNr; RdCnt :integer);
    procedure SeWriteFile(SesId : TSesID; AskC : word; FileNr : TFileNr; WrCnt :integer);
    procedure SeSeek(SesId : TSesID; AskC : word; FileNr : TFileNr; Offset  : integer; Orgin : byte);
    procedure SeGetFileSize(SesId : TSesID; AskC : word; FileNr : TFileNr);
    procedure SeCloseFile(SesId : TSesID; AskC : word; FileNr : TFileNr);
    procedure SeGetGuid(SesId : TSesID; AskC : word; FileNr : TFileNr);
  end;

  TDate    = record
             rk : word;
             ms : byte;
             dz : byte;
             gd : byte;
             mn : byte;
             sc : byte;
             st : byte;
           end;

  TRsdSoftInfo = record
           Ver : word;
           Rev : word;
           Time : TDATE;
         end;


{$A+}

TOnProgress   = procedure(Sender: TObject; Pos : real) of object;
type
  TChannel = (chHOST,chBECK);

TMemSesIdObj = class(TObject)
  Channel   : TChannel;
  OrgSesId  : TsesId;
  SesId     : TsesId;
end;


TDevice = class(TObject)
  private
    AccID         : integer;
    DevId         : integer;       // numer w module wywolujacym
    MyIpD         : Cardinal;      // Ip w postaci liczby Cardinal
    SmTcp         : TSimpTcp;
    FOnProgress   : TOnProgress;
    FCallBackFunc : TCallBackFunc;
    FCmmId        : integer;
    glProgress    : boolean;       // false -> progress wysy³a procedura Konwers
    glToReadCnt   : integer;
    glReadSuma    : integer;
    BreakFlag     : boolean;
    FAskNr        : word;
    BeckSoftVer   : TBeckSoftVer;
    MaxRdTab      : array[TChannel] of integer;
    MaxWrTab      : array[TChannel] of integer;
    SafetySection: TRTLCriticalSection;

    //    function   CheckSuma(const Header:TNetQuery;  const Buf; Len:integer): boolean;
    function   SendQuery(Channel : TChannel; const SndHeader : TNetQuery; const Buf; DtSize: cardinal): TStatus;
    function   RecivAnswer(var RecHeader:TNetQuery; var Buf;var  SizeR:integer; RecTime : integer): TStatus;
    function   CheckBeckFrame(AskHead,ReplyHead : TNetQuery; var CanRep: boolean): TStatus;
    function   CheckHostFrame(AskHead,ReplyHead : TNetQuery; var CanRep: boolean): TStatus;

    function   Konwers(Channel : TChannel; var Header:TNetQuery;
                const WrBuffer; SizeW : integer;
                var RdBuffer; var SizeR: integer;
                RecTime : integer): TStatus; overload;
    function   Konwers(Channel : TChannel; var Header:TNetQuery; var RdBuffer; var SizeR: integer; RecTime : integer): TStatus; overload;
    function   Konwers(Channel : TChannel; var Header:TNetQuery; RecTime : integer): TStatus; overload;

    function   SeKonwers(Channel : TChannel; var Header:TNetQuery; const WrBuffer; SizeW : integer;
                 var RdBuffer; var SizeR: integer; RecTime : integer): TStatus; overload;
    function   SeKonwers(Channel : TChannel; var Header:TNetQuery; var Buffer; var SizeR: integer; RecTime : integer): TStatus; overload;
    function   SeKonwers(Channel : TChannel; var Header:TNetQuery; RecTime : integer): TStatus; overload;
    function   CheckOpen: TStatus;
    function   GetNewAskNr: word;
    function   SeReadFileHd(Channel:TChannel; SesId : TSesID;  FileNr : TFileNr; var buf; var Cnt : integer):TStatus;
    function   SeWriteFileHd(Channel:TChannel; SesId : TSesID; FileNr : TFileNr; const buf; var Cnt : integer):TStatus;
    function   SeGetDirHd(Channel  : TChannel; First : boolean; SesId : TSesID; FName : pchar; Attrib : byte;
                 var Buffer; MaxLen : integer; var Len : integer):TStatus;
    function   ProtokolAligment : TStatus;
    function   SeGetDirToStream(Channel : TChannel; SesId : TSesID; FName : pchar; Attrib : byte; Stream : TMemoryStream):TStatus;
  protected
    procedure  MsgRdFlowSize(Sender :TObject;R: real);
    procedure  GoBackFunct(Ev: integer; R: real);
    procedure  SetProgress(F: real); overload;
    procedure  SetProgress(Cnt,Max:integer); overload;
    procedure  SetWorkFlag(w : boolean);
    procedure  MsgFlowSize(R: real);

    function   ReadM(Channel : TChannel; var Buffer; adr : Cardinal; size : integer): TStatus;
    function   WriteM(Channel : TChannel; var Buffer; adr : Cardinal; size : integer): TStatus;
  public
    LastOkTransm : Cardinal;  // czas ostatniej poprawnej ramki
    constructor Create(AIp : string; APort : word);
    destructor Destroy; override;

    function   Open : TStatus;
    function   Close : TStatus;
    function   SetBreakFlag(Val : boolean):integer;
    property   OnProgress : TOnProgress read FOnProgress write FOnProgress;
    procedure  RegisterCallBackFun(ACallBackFunc : TCallBackFunc; CmmId : integer);
    function   GetDrvStatus(ParamName : pchar; ParamValue :pchar; MaxRpl:integer): TStatus;
    function   SetDrvParam(ParamName : pchar; ParamValue :pchar): TStatus;


    // Procedury komunikacyjne z H8
    function   ReadS(Channel : TChannel; var DevCode; var TabVec:cardinal): TStatus;
    function   ReadDevInfo(Channel : TChannel; var DevInfo :TDevInfo): TStatus;

    function   ReadReg(Channel : TChannel; var Buffer): TStatus;
    function   WriteCtrl(Channel : TChannel; nr: byte; b: byte): TStatus;
    function   ReadCtrl(Channel : TChannel; nr : byte; var b : byte): TStatus;
    function   ReadMem(Channel : TChannel; var Buffer; adr : cardinal; size : Cardinal): TStatus;
    function   WriteMem(Channel : TChannel; var Buffer; adr : cardinal; size : Cardinal): TStatus;

    // obs³uga plików
    function  SeOpenSesion(Channel : TChannel; var SesId : TSesID) : TStatus;
    function  GetErrStr(Channel : TChannel; Code :TStatus; S : pChar; Max: integer): boolean;
    function  SeCloseSesion(Channel : TChannel; SesId : TSesID) : TStatus;
    function  SeOpenFile(Channel : TChannel; SesId : TSesID; FName : pchar; Mode : byte; var FileNr : TFileNr):TStatus;
    function  SeGetDir(Channel : TChannel; SesId : TSesID; FName : pchar; Attrib : byte; Buffer : pchar; MaxLen : integer):TStatus;
    function  SeGetDir2(Channel : TChannel; SesId : TSesID; FName : pchar; Attrib : byte; var ExBuffer : pchar; GetMemFunc : TGetMemFunc):TStatus;


    function  SeGetDrvList(Channel : TChannel; SesId : TSesID; DrvList : pchar):TStatus;
    function  SeShell(Channel : TChannel; SesId : TSesID; Command : pchar; ResultStr : pchar; MaxLen : integer):TStatus;
    function  SeGetGuidEx(Channel : TChannel; SesId : TSesID; FileName : pchar; var Guid : TSeGuid):TStatus;
    function  SeReadFileEx(Channel : TChannel; SesId : TSesID; FileName : pchar; autoclose: boolean; var buf;
              var size: integer; var FileNr: TFileNr):TStatus;

    function  SeReadFile(Channel : TChannel; SesId : TSesID;  FileNr : TFileNr; var buf; var Cnt : integer):TStatus;
    function  SeWriteFile(Channel : TChannel; SesId : TSesID; FileNr : TFileNr; const buf; var Cnt : integer):TStatus;
    function  SeSeek(Channel : TChannel; SesId : TSesID; FileNr : TFileNr; Offset  : integer; Orgin : byte; var Pos : integer):TStatus;
    function  SeGetFileSize(Channel : TChannel; SesId : TSesID; FileNr : TFileNr; var FileSize : integer):TStatus;
    function  SeCloseFile(Channel : TChannel; SesId : TSesID;  FileNr : TFileNr):TStatus;
    function  SeGetGuid(Channel : TChannel; SesId : TSesID;  FileNr : TFileNr; var Guid : TSeGuid):TStatus;
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
    function  FindId(AccId : TAccId; var Channel : TChannel):TDevice; overload;
    function  FindId(AccId : TAccId):TDevice; overload;
    function  FindIp(IPD : cardinal):TDevice;
  end;


var
  GlobDevList : TDevList;
  EmulateVer  : integer;
  ApplicationName : string;

const
  stEND_OFF_DIR     = -25;
  NUM_FOR_CONNECT   = 10;  // iloœæ AccId dozwolonych dla jednego po³¹czenia

//  ----------   NET ----------------------------------------------------------

{ budowa ramki }
  RMK_KOD    = 0;  { 1 bajt  }
  RMK_ADR1   = 1;  { 3 bajty }
  RMK_ADR2   = 4;  { 3 bajty }
  RMK_SIZE   = 7;  { 3 bajty }
  RMK_SIGN   = 10; { 1 bajt  }
  RMK_SUMAEX = 13; { 2 bajty }
  RMK_SUMA   = 15; { 1 bajt }
  RMK_SFR_NR = 1;  { 1 bajt }
  RMK_SFR_DT = 2;  { 1 bajt }

function DSwap(X : Cardinal):cardinal;
begin
  Result := Swap(X shr 16) or (Swap(x and $ffff) shl 16);
end;

procedure TNetQuery.Finish;
begin


end;

procedure TNetQuery.Init;
begin
  fillchar(self,sizeof(self),0);
  AskFrameCnt := 0;
end;

procedure TNetQuery.Init(SesId : TSesID; AskC : word);
begin
  Init;
  Body.QrCmd := 'F';   // FIleCommand
  AskFrame.AskCnt := Swap(AskC);
  AskFrame.SesionID := DSwap(SesId);
end;

procedure TNetQuery.GetProtokolVersion;
begin
  Init;
  Body.QrCmd := #255;
  Body.VarB  := 0;
  Finish;
end;

procedure TNetQuery.SetEmulateVer(BeckSoftVer : TBeckSoftVer);
begin
  Init;
  Body.QrCmd := #254;
  Body.VarB  := ord(BeckSoftVer)+1;
  Finish;
end;


procedure TNetQuery.ReadS;
begin
  Init;
  Body.QrCmd:='S';
  Finish;
end;

procedure TNetQuery.ReadDevInfo;
begin
  Init;
  Body.QrCmd:='V';
  Finish;
end;




procedure TNetQuery.ReadM(adr : cardinal; aSize : integer);
begin
  Init;
  Body.QrCmd:='R';
  Body.Adr1:=DSwap(Adr);
  Body.Size:=DSwap(aSize);
  Finish;
end;

procedure TNetQuery.ReadReg;
begin
  Init;
  Body.QrCmd:='I';
  Finish;
end;

procedure TNetQuery.WriteM(adr : cardinal; aSize : integer);
begin
  Init;
  Body.QrCmd:='W';
  Body.Adr1:=DSwap(Adr);
  Body.Size:=DSwap(aSize);
  Finish;
end;

procedure TNetQuery.ReadCtrl(ANr : byte);
begin
  Init;
  Body.QrCmd:='K';
  Body.VarB:=aNr;
  Finish;
end;


procedure TNetQuery.WriteCtrl(ANr: byte; AVal: byte);
begin
  Init;
  Body.QrCmd:='M';
  Body.VarB:=aNr;
  Body.VarB2:=AVal;
  Finish;
end;

function TNetQuery.GetName:string;
begin
  Result := Body.DevName[0]+Body.DevName[1]+Body.DevName[2]+Body.DevName[3]+Body.DevName[4];
end;
function  TNetQuery.GetTabVec: Cardinal;
begin
  Result := Body.DevVec and $ffffff;
end;


//    File Command   ---------------------------------------------------------

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

procedure TNetQuery.GetErrStr(Code :TStatus);
begin
  Init(0,0);
  Body.VarB := crdGetErrorStr;
  AskFrame.AskCnt := Swap(word(Code));  // tutaj -> kod b³êdu
  AskFrameCnt := sizeof(AskFrame.AskCnt);
  Body.Size := DSwap(AskFrameCnt);
  Finish;
end;


procedure TNetQuery.SeOpenSesion(AplName : string);
begin
  Init(0,0);
  Body.QrCmd := 'F';
  Body.VarB := crdOpenSesion;
  strPLcopy(AskFrame.Command,AplName,sizeof(AskFrame.Command));
  AskFrameCnt := sizeof(AskFrame.SesionID)+sizeof(AskFrame.AskCnt)+
    strlen(AskFrame.Command)+1;
  Body.Size := DSwap(AskFrameCnt);
  Finish;
end;

procedure TNetQuery.SeCloseSesion(SesId : TSesID; AskC : word);
begin
  Init(SesId,AskC);
  Body.VarB := crdCloseSesion;
  AskFrameCnt := sizeof(AskFrame.SesionID)+sizeof(AskFrame.AskCnt);
  Body.Size := DSwap(AskFrameCnt);
  Finish;
end;

procedure TNetQuery.SeOpenFile(SesId : TSesID; AskC : word; FName : pchar; Mode : byte);
begin
  Init(SesId,AskC);
  Body.VarB := crdOpenFile;
  AskFrame.OpenMode := Mode;
  AskFrame.Free :=0;
  strLcopy(AskFrame.FName,Fname,sizeof(AskFrame.FName));
  AskFrameCnt := sizeof(AskFrame.SesionID)+sizeof(AskFrame.AskCnt)+
    sizeof(AskFrame.OpenMode)+sizeof(AskFrame.Free)+StrLen(AskFrame.FName)+1;
  Body.Size := DSwap(AskFrameCnt);
  Finish;
end;

const
  mdDirStd  =0;
  mdDirGuid =1;
  mdDirUnix =2;

procedure TNetQuery.SeGetDir(SesId : TSesID; AskC : word;  First :boolean; APath : pchar; Attrib : byte);
begin
  Init(SesId,AskC);
  Body.VarB := crdGetDirs;
  if First then
    AskFrame.First := 1
  else
    AskFrame.First := 0;
  AskFrame.Attrib  := Attrib;
  AskFrame.Mode    := mdDirStd;
  AskFrame.Free3   := 0;
  AskFrame.Mode    := 0;
  strLcopy(AskFrame.Path,APath,sizeof(AskFrame.Path));
  AskFrameCnt := sizeof(AskFrame.SesionID)+sizeof(AskFrame.AskCnt)+
    sizeof(AskFrame.First)+sizeof(AskFrame.Attrib)+
    sizeof(AskFrame.Free3)+sizeof(AskFrame.Mode)+
    StrLen(AskFrame.Path)+1;
  Body.Size := DSwap(AskFrameCnt);
  Finish;
end;

procedure TNetQuery.SeGetDrvList(SesId : TSesID; AskC : word);
begin
  Init(SesId,AskC);
  Body.VarB := crdGetDriveList;
  AskFrameCnt := sizeof(AskFrame.SesionID)+sizeof(AskFrame.AskCnt);
  Body.Size := DSwap(AskFrameCnt);
  Finish;
end;

procedure TNetQuery.SeShell(SesId : TSesID; AskC : word; Command : pchar);
begin
  Init(SesId,AskC);
  Body.VarB := crdShell;
  strLcopy(AskFrame.Command,Command,sizeof(AskFrame.Command));
  AskFrameCnt := sizeof(AskFrame.SesionID)+sizeof(AskFrame.AskCnt)+
    strlen(AskFrame.Command)+1;
  Body.Size := DSwap(AskFrameCnt);
  Finish;
end;

procedure TNetQuery.SeReadFileEx(SesId : TSesID; AskC : word; FName : pchar; AutoClose: boolean; Size : byte);
begin
  Init(SesId,AskC);
  Body.VarB := crdReadEx;
  AskFrame.AutoClose := byte(AutoClose);
  AskFrame.SizeToRead := Size;
  strLcopy(AskFrame.FName,Fname,sizeof(AskFrame.FName));

  AskFrameCnt := sizeof(AskFrame.SesionID)+sizeof(AskFrame.AskCnt)+
    sizeof(AskFrame.AutoClose)+sizeof(AskFrame.SizeToRead)+StrLen(AskFrame.FName)+1;
  Body.Size := DSwap(AskFrameCnt);
  Finish;
end;

procedure TNetQuery.SeGetGuidEx(SesId : TSesID; AskC : word; FName : pchar);
begin
  Init(SesId,AskC);
  Body.VarB := crdGetGuidEx;
  AskFrame.OpenMode := 0;
  AskFrame.Free :=0;
  strLcopy(AskFrame.FName,Fname,sizeof(AskFrame.FName));
  AskFrameCnt := sizeof(AskFrame.SesionID)+sizeof(AskFrame.AskCnt)+
    sizeof(AskFrame.OpenMode)+sizeof(AskFrame.Free)+StrLen(AskFrame.FName)+1;
  Body.Size := DSwap(AskFrameCnt);
  Finish;
end;


procedure TNetQuery.SeReadFile(SesId : TSesID; AskC : word; FileNr : TFileNr; RdCnt :integer);
begin
  Init(SesId,AskC);
  Body.VarB := crdRead;
  AskFrame.FileNr1 := FileNr;
  AskFrame.BArg1 := 0;
  AskFrame.Arg1  := DSwap(RdCnt);
  AskFrameCnt := sizeof(AskFrame.SesionID)+sizeof(AskFrame.AskCnt)+
    sizeof(AskFrame.FileNr1)+sizeof(AskFrame.BArg1)+sizeof(AskFrame.Arg1);
  Body.Size := DSwap(AskFrameCnt);
  Finish;
end;

procedure TNetQuery.SeWriteFile(SesId : TSesID; AskC : word; FileNr : TFileNr; WrCnt :integer);
begin
  Init(SesId,AskC);
  Body.VarB := crdWrite;
  AskFrame.FileNr1 := FileNr;
  AskFrame.BArg1 := 0;
  AskFrame.Arg1  := DSwap(WrCnt);
  AskFrameCnt := sizeof(AskFrame.SesionID)+sizeof(AskFrame.AskCnt)+
    sizeof(AskFrame.FileNr1)+sizeof(AskFrame.BArg1);
  Body.Size := DSwap(AskFrameCnt+WrCnt);
  Finish;
end;

procedure TNetQuery.SeSeek(SesId : TSesID; AskC : word; FileNr : TFileNr; Offset  : integer; Orgin : byte);
begin
  Init(SesId,AskC);
  Body.VarB := crdSeek;

  AskFrame.FileNr1 := FileNr;
  AskFrame.BArg1 := Orgin;
  AskFrame.Arg1  := DSwap(cardinal(Offset));
  AskFrameCnt := sizeof(AskFrame.SesionID)+sizeof(AskFrame.AskCnt)+
    sizeof(AskFrame.FileNr1)+sizeof(AskFrame.BArg1)+sizeof(AskFrame.Arg1);
  Body.Size := DSwap(AskFrameCnt);
  Finish;
end;

procedure TNetQuery.SeGetFileSize(SesId : TSesID; AskC : word; FileNr : TFileNr);
begin
  Init(SesId,AskC);
  Body.VarB := crdGetFileSize;

  AskFrame.FileNr1 := FileNr;
  AskFrameCnt := sizeof(AskFrame.SesionID)+sizeof(AskFrame.AskCnt)+
    sizeof(AskFrame.FileNr1);
  Body.Size := DSwap(AskFrameCnt);
  Finish;
end;

procedure TNetQuery.SeCloseFile(SesId : TSesID; AskC : word; FileNr : TFileNr);
begin
  Init(SesId,AskC);
  Body.VarB := crdClose;

  AskFrameCnt := sizeof(AskFrame.SesionID)+sizeof(AskFrame.AskCnt)+
    sizeof(AskFrame.FileNr1);
  Body.Size := DSwap(AskFrameCnt);
  Finish;
end;

procedure TNetQuery.SeGetGuid(SesId : TSesID; AskC : word; FileNr : TFileNr);
begin
  Init(SesId,AskC);
  Body.VarB := crdGetGuid;

  AskFrameCnt := sizeof(AskFrame.SesionID)+sizeof(AskFrame.AskCnt)+
    sizeof(AskFrame.FileNr1);
  Body.Size := DSwap(AskFrameCnt);
  Finish;
end;

//-------------------- TDevice -----f-----------------------------------------
const
  REQ_TSHB     = $10;
  REQ_OWN      = $11;
  REQ_CTRL     = $12;
  REQ_H8       = $13;
  ChannelCode : array[TChannel] of word = (REQ_H8,REQ_OWN);

  MAX_SENS_SIZE = 32*1024; //32kB

constructor TDevice.Create(AIp : string; APort : word);
begin      
  inherited Create;
  InitializeCriticalSection(SafetySection);
  DevId := DevId;
  SmTcp := TSimpTcp.Create;
  SmTcp.Ip := AIp;
  SMTcp.Port := APort;
  FCallBackFunc := nil;
  FAskNr := 0;
  MaxRdTab[chHOST] := 8*1024;
  MaxWrTab[chHOST] := 1024;
  MaxRdTab[chBECK] := 1024;
  MaxWrTab[chBECK] := 1024;
end;

destructor TDevice.Destroy;
begin
  FreeAndNil(SmTcp);
  DeleteCriticalSection(SafetySection);

  inherited;
end;


function TDevice.Open : TStatus;
var
  st : TStatus;
begin
  SmTcp.RecWaitTime := 10000; // !!!! nie zmieniaæ po wykoananiu open
  Result := SmTcp.Open;
  if Result=stOk then
    Result := SmTcp.Connect;
  if Result=stOk then
  begin
    st := ProtokolAligment;
    if (st = WSAECONNRESET) or (st= WSAENOTCONN) then
    begin
      Result := st;
    end;
  end;
  LastOkTransm := GetTickCount;
end;

function TDevice.Close : TStatus;
begin
  Result := SmTcp.Close;
end;

function TDevice.GetDrvStatus(ParamName : pchar; ParamValue :pchar; MaxRpl:integer): TStatus;
var
  s : string;
begin
  s := '';
  if ParamName='PROTOCOL_VER'then s := IntToStr(ord(BeckSoftVer)+1);
  if s<>'' then
  begin
    StrPLCopy(ParamValue,s,MaxRpl);
    Result := stOK;
  end
  else
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

function TDevice.SendQuery(Channel : TChannel; const SndHeader : TNetQuery; const Buf; DtSize: cardinal): TStatus;

var
  MemStr   : TMyMemoryStream;
  SS       : Cardinal;
  SSV      : Cardinal;

{$IFDEF WINDEBUG}
  Errstr : String;
{$ENDIF}

begin
  MemStr := TMyMemoryStream.Create;
  try
      try
          //MemStr.Capacity := 8000;
          SS := sizeof(word)+sizeof(SndHeader.Body)+DtSize+cardinal(SndHeader.AskFrameCnt);
          SSV:= DSwap(SS);
          MemStr.Write(SSV,sizeof(SS));
          MemStr.Write(ChannelCode[Channel],sizeof(word));
          MemStr.Write(SndHeader.Body,sizeof(SndHeader.Body));

          if SndHeader.AskFrameCnt<>0 then
            MemStr.Write(SndHeader.AskFrame,SndHeader.AskFrameCnt);

          if DtSize<>0 then
            MemStr.Write(Buf,DtSize);

          Result := SmTcp.WriteStream(MemStr);

          SmTcp.MsgFlow := nil;

      {
          if (Result = WSAECONNRESET) or (Result = WSAENOTCONN) then
          begin
            Result:=SmTcp.ReOpen;
            if Result=stOk then
               Result := SmTcp.WriteStream(Stream);
          end;
      }
      except
         on E: EOutOfMemory do
            begin
              result := stNoMemory;
             {$IFDEF WINDEBUG}
              ErrStr := Format('Exception in %s.SendQuery: %s',[ClassName,E.Message]);
              OutputDebugString(PChar(ErrStr));
             {$ENDIF}
            end;
         else begin
           result := stException;
         end;

      end;
  finally
    MemStr.Free;
  end;
end;

{
function TDevice.CheckSuma(const Header:TNetQuery; const Buf; Len:integer): boolean;
var
  i    : cardinal;
  Suma : word;
  pb   : pByte;
begin
  pb := pbyte(@Buf);
  Suma:=0;
  for i:=0 to Len-1 do
  begin
    Suma := word(Suma+pb^);
    inc(pb);
  end;
  Result:=(Suma=Header.SumaEx);
end;
}
function  TDevice.RecivAnswer(var RecHeader:TNetQuery; var Buf;var SizeR:integer; RecTime : integer): TStatus;
var
  Typ      : word;
  Size     : cardinal;
  L        : integer;
  T        : cardinal;
begin
  SmTcp.RecWaitTime := RecTime;
  T := GetTickCount;
  Result := SmTcp.ReciveToBufTime(T,Size,Sizeof(Size));             if Result<>stOk then Exit;
  Result := SmTcp.ReciveToBufTime(T,Typ,Sizeof(Typ));               if Result<>stOk then Exit;
  Result := SmTcp.ReciveToBufTime(T,RecHeader.Body,Sizeof(TBody));  if Result<>stOk then Exit;
//  if not(RecHeader.CheckSuma) then
//    Result := stSumHeaderError;
  if Result=stOk then
  begin
    Size := SmTcp.DSwap(Size);
    L := integer(Size)-(Sizeof(Typ)+Sizeof(TBody));
    if L<=SizeR then
    begin
      SizeR := L;
      if L<>0 then
      begin
        if not(glProgress) then
        begin
          glToReadCnt := L;
          glReadSuma := 0;
        end;
        SmTcp.MsgFlow := MsgRdFlowSize;
        Result := SmTcp.ReciveToBufTime(T,buf,L);
        SmTcp.MsgFlow := nil;
      end;
    end
    else
    begin
      Result := stTooMuchRecData; // 'Zbyt du¿o odebranych danych'
    end;
  end;
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


function TDevice.CheckBeckFrame(AskHead,ReplyHead : TNetQuery; var CanRep: boolean): TStatus;
begin
  CanRep:=false;
  Result := stOK;
  case BeckSoftVer of
  bVer3:
    if ReplyHead.Body.QrCmd<>AskHead.Body.QrCmd then
    begin
      if ReplyHead.Body.QrCmd<>AskHead.Body.QrCmd then
      begin
        if ord(ReplyHead.Body.QrCmd)=(ord(AskHead.Body.QrCmd) xor $80) then
          Result := Swap(ReplyHead.Body.ErrCode)
        else
          Result := stUnkBeckRepl;
      end;
    end;
  bVer2:
    if ReplyHead.Body.QrCmd<>AskHead.Body.QrCmd then
    begin
      if ord(ReplyHead.Body.QrCmd)=(ord(AskHead.Body.QrCmd) xor $80) then
      begin
        case ReplyHead.Body.VarB of
        tkNoAck:   Result := stAckTimeErr;
        tkNoRepl:  Result := stTimeErr;
        tkReplCodeErr : Result := stBadHostRepl;
        tkUnkFunc     : Result := stUnkHostFunct;
        tkBadParams   : Result := stBadParams;
        else
          Result := stUnkBeckRepl;
        end;
      end
      else
        Result := stUnkBeckRepl;
    end
  else
    begin


    end;
  end;
end;

function TDevice.CheckHostFrame(AskHead,ReplyHead : TNetQuery; var CanRep: boolean): TStatus;
begin
  Result := stOK;
  case BeckSoftVer of
  bVer1 : begin
            case ReplyHead.Body.QrCmd of
            'A' : ;
            else
              Result := stBadHostRepl;
            end;
          end;
  bVer2 : begin
            if ReplyHead.Body.QrCmd<>AskHead.Body.QrCmd then
            begin
              if ord(ReplyHead.Body.QrCmd)=(ord(AskHead.Body.QrCmd) xor $80) then
              begin
                case ReplyHead.Body.VarB of
                tkNoAck       : Result := stAckTimeErr;
                tkNoRepl      : Result := stTimeErr;
                tkReplCodeErr : Result := stBadHostRepl;
                tkUnkFunc     : Result := stUnkHostFunct;
                tkH8Error     : Result := stH8Error;
                else
                  Result := stUnkBeckRepl;
                end;
              end
              else
                Result := stUnkBeckRepl;
            end;
          end;
  bVer3 : begin
            if ReplyHead.Body.QrCmd<>AskHead.Body.QrCmd then
            begin
              if ord(ReplyHead.Body.QrCmd)=(ord(AskHead.Body.QrCmd) xor $80) then
                Result := Swap(ReplyHead.Body.ErrCode)
              else
                Result := stUnkBeckRepl;
            end;
          end;
  end;
  CanRep := (Result=stSumHeaderError) or
            (Result=stSumBufError);
end;

function TDevice.Konwers(Channel : TChannel; var Header:TNetQuery;
     const WrBuffer; SizeW : integer;
     var RdBuffer; var SizeR: integer;
     RecTime : integer): TStatus;
var
  Rep       : integer;
  CanRep    : boolean;
  ReplyHead : TNetQuery;
begin
  Result:=CheckOpen;
  if Result<>stOk then Exit;
  Rep:=0;
  if not(glProgress) then
    SetProgress(0);
  SetWorkFlag(true);
  while Rep<2 do
  begin
    inc(Rep);
    Result := SmTcp.ClearInpBuf;
    if Result=stOk then
      Result := SendQuery(Channel,Header,WrBuffer,SizeW);
    if Result=stOk then
      Result := RecivAnswer(ReplyHead,RdBuffer,SizeR,RecTime);
    if Result=stOk then
    begin
      CanRep := false;
      case Channel of
      chBECK : Result := CheckBeckFrame(Header,ReplyHead,CanRep);
      chHOST : Result := CheckHostFrame(Header,ReplyHead,CanRep);
      end;
    end;
    if Rep=2 then Break;
{
    if Result=WSAETIMEDOUT then
    begin
      Result := SmTcp.ReOpen;
      ProtokolAligment;
      CanRep := True;
    end;
}
    if not(CanRep) then break;
  end;

  if Result=stOk then
  begin
    if not(glProgress) then
      SetProgress(100);
    LastOkTransm := GetTickCount;
  end;
  SetWorkFlag(false);
  Header := ReplyHead;
end;

function   TDevice.Konwers(Channel : TChannel; var Header:TNetQuery; var RdBuffer; var SizeR: integer; RecTime : integer): TStatus;
var
  x : integer;
begin
  x:=0;
  Result := Konwers(Channel,Header,x,0,RdBuffer,SizeR,RecTime);
end;

function TDevice.Konwers(Channel : TChannel; var Header:TNetQuery; RecTime : integer): TStatus;
var
  x : integer;
begin
  x:=0;
  Result := Konwers(Channel,Header,x,0,x,x,RecTime);
end;

function TDevice.SeKonwers(Channel : TChannel; var Header:TNetQuery; const WrBuffer; SizeW : integer;
  var RdBuffer; var SizeR: integer; RecTime : integer): TStatus;
var
  st : smallint;
begin
  Result := Konwers(Channel,Header,WrBuffer,SizeW,RdBuffer,SizeR,RecTime);
  if Result=stOk then
  begin
    case BeckSoftVer of
    bVer3 :
      st := Swap(Header.Body.ErrCode);
    else
      st := Swap(Header.Body.VarW);
    end;

    if st<>stOk then
      Result := st;
  end;
end;

function TDevice.SeKonwers(Channel : TChannel; var Header:TNetQuery; var Buffer; var SizeR: integer; RecTime : integer): TStatus;
var
  x : integer;
begin
  Result := SeKonwers(Channel,Header,x,0,Buffer,SizeR,RecTime);
end;

function TDevice.SeKonwers(Channel : TChannel; var Header:TNetQuery; RecTime : integer): TStatus;
var
  x : integer;
begin
  x:=0;
  Result := SeKonwers(Channel,Header,x,0,x,x,RecTime);
end;

function TDevice.ReadS(Channel : TChannel; Var DevCode; var TabVec:cardinal): TStatus;
var
  Header : TNetQuery;
  p      : pByte;
begin
  Header.ReadS;
  Result := Konwers(Channel,Header,4000);
  move(Header.Body.DevName,DevCode,5);
  p:=pByte(@DevCode);
  inc(p,5);
  p^:=0;
  TabVec :=Header.GetTabVec;
end;

function TDevice.ReadDevInfo(Channel : TChannel; var DevInfo :TDevInfo): TStatus;
var
  Header : TNetQuery;
  recLen : integer;
begin
  Header.ReadDevInfo;
  RecLen := sizeof(TDevInfo);
  Result := Konwers(Channel,Header,DevInfo,RecLen,4000);
  if Result =stOK then
  begin
    DevInfo.DspDataBase := DSwap(DevInfo.DspDataBase);
    DevInfo.DspDataSize := DSwap(DevInfo.DspDataSize);
    DevInfo.DspProgBase := DSwap(DevInfo.DspProgBase);
    DevInfo.DspProgSize := DSwap(DevInfo.DspProgSize);
  end;
end;






function TDevice.ReadM(Channel : TChannel; var Buffer; adr : cardinal; size : integer): TStatus;
var
  Header   : TNetQuery;
begin
  Header.ReadM(adr,Size);
  Result := Konwers(Channel,Header,Buffer,Size,10000);
  //=======  Result := Konwers(Channel,Header,Buffer,Size,30000); >>>>>>> 1.20
end;

function TDevice.ReadReg(Channel : TChannel;  var Buffer): TStatus;
var
  Header : TNetQuery;
  N      : integer;
begin
  Header.ReadReg;
  N := 38;
  Result := Konwers(Channel,Header,Buffer,N,10000);
end;

function TDevice.WriteM(Channel : TChannel;  var Buffer; adr : cardinal; size : integer): TStatus;
var
  Header : TNetQuery;
  N      : integer;
begin
  Header.WriteM(adr,Size);
  N := 0;
  Result := Konwers(Channel,Header,Buffer,Size,N,N,30000);
end;

function TDevice.WriteCtrl(Channel : TChannel;  nr: byte; b: byte): TStatus;
var
  Header : TNetQuery;
begin
  Header.WriteCtrl(nr,b);
  Result:=Konwers(Channel,Header,10000);
end;

function TDevice.ReadCtrl(Channel : TChannel;  nr : byte; var b : byte): TStatus;
var
  Header : TNetQuery;
begin
  Header.ReadCtrl(nr);
  Result:=Konwers(Channel,Header,10000);
  b := Header.Body.VarB2;
end;

function TDevice.ReadMem(Channel : TChannel; var Buffer; adr : cardinal; size : Cardinal): TStatus;
var
  Wsk        : Cardinal;
  size1      : integer;
  DoSize     : integer;
  pb         : pbyte;
  MaxSize    : integer;
begin
  if Size=0 then
  begin
    Result := stOK;
    Exit;
  end;
  MaxSize := MaxRdTab[Channel];
  Wsk :=0;
  DoSize := Size;
  pb     := pByte(@Buffer);
  glProgress  := true;
  glToReadCnt := size;
  glReadSuma  := 0;
  SetWorkFlag(true);
  SetProgress(0);
  repeat
    Size1 := Min(MaxSize,Size);
    Result := ReadM(Channel,pB^,adr,size1);
    inc(wsk,Size1);
    inc(adr,Size1);
    dec(Size,Size1);
    inc(pb,Size1);
    glReadSuma := Wsk;
    SetProgress(Wsk,DoSize);
  until (Size=0) or (Result<>stOk);
  SetProgress(100);
  SetWorkFlag(false);
  glProgress  := false;
end;

function TDevice.WriteMem(Channel : TChannel; var Buffer; adr : Cardinal; size : Cardinal): TStatus;
var
  Wsk        : Cardinal;
  size1      : integer;
  DoSize     : integer;
  pb         : pbyte;
  MaxSize    : integer;
begin
  if Size=0 then
  begin
    Result := stOK;
    Exit;
  end;
  MaxSize := MaxWrTab[Channel];
  Wsk :=0;
  DoSize := Size;
  pb     := pByte(@Buffer);
  glProgress  := true;
  glToReadCnt := size;
  glReadSuma  := 0;
  SetProgress(0);
  SetWorkFlag(true);
  repeat
    Size1 := Min(Size,MaxSize);
    Result:=WriteM(Channel,pB^,adr,size1);
    if Result=stOk then
    begin
      inc(wsk,Size1);
      inc(adr,Size1);
      dec(Size,Size1);
      inc(pb,Size1);
      glReadSuma := Wsk;
      SetProgress(Wsk,DoSize);
    end;
  until (Size=0) or (Result<>stOk);
  SetProgress(100);
  SetWorkFlag(false);
  glProgress  := false;
end;

//!!!
function  TDevice.GetNewAskNr: word;
begin
  EnterCriticalSection(SafetySection);
  try
    if FAskNr=MaxWord then
       FAskNr := 0;
    inc(FAskNr);
    Result := FAskNr;
  finally
     leaveCriticalSection(SafetySection);
  end;
end;

function  TDevice.SeOpenSesion(Channel : TChannel; var SesId : TSesID) : TStatus;
var
  Header   : TNetQuery;
  L        : integer;
begin
  Header.SeOpenSesion(ApplicationName);
  L := sizeof(sesID);

  Result:=SeKonwers(Channel,Header,SesId,L,10000);
  if Result=stOk then
  begin
    SesId := DSwap(SesId);
    if L <> sizeof(SesId) then
      Result:=stBadReplay;
  end;
end;

function  TDevice.SeCloseSesion(Channel : TChannel;SesId : TSesID) : TStatus;
var
  Header   : TNetQuery;
begin
  Header.SeCloseSesion(SesId,GetNewAskNr);
  Result:=SeKonwers(Channel,Header,10000);
end;

function  TDevice.GetErrStr(Channel  : TChannel; Code :TStatus; S : pChar; Max: integer): boolean;
var
  Header   : TNetQuery;
begin
  Header.GetErrStr(Code);
  Result:=(SeKonwers(Channel,Header,S^,Max,3000)=stOk);
end;

function  TDevice.SeOpenFile(Channel  : TChannel; SesId : TSesID; FName : pchar; Mode : byte; var FileNr : TFileNr):TStatus;
var
  Header : TNetQuery;
  L      : integer;
  F1     : smallint;
begin
  Header.SeOpenFile(SesId,GetNewAskNr,FName,Mode);
  L := sizeof(F1);
  FileNr := 255;
  Result:=SeKonwers(Channel,Header,F1,L,10000);
  if Result=stOk then
  begin
    FileNr := byte(F1);
    if L <> sizeof(F1) then
      Result:=stBadReplay;
  end;
end;


function  TDevice.SeGetDirHd(Channel  : TChannel; First : boolean; SesId : TSesID; FName : pchar; Attrib : byte;
   var Buffer; MaxLen : integer; var Len : integer):TStatus;
var
  Header : TNetQuery;
  L      : integer;
begin
  Header.SeGetDir(SesId,GetNewAskNr,First,FName,Attrib);
  L := MaxLen;
  Result := SeKonwers(Channel,Header,Buffer,L,10000);
  Len := L;
end;

function TDevice.SeGetDirToStream(Channel : TChannel; SesId : TSesID; FName : pchar; Attrib : byte; Stream : TMemoryStream):TStatus;
var
  Len   : integer;
  p     : pchar;
  Buffer  : array of char;
  a       : char;
begin
  SetLength(Buffer,60000);
  Buffer[0]:=#0;

  Result := SeGetDirHd(Channel,true,SesId,FName,Attrib,Buffer[0],length(Buffer),Len);
  while (Result=stOk) and (Len>0) do
  begin
    Stream.Write(Buffer[0],Len);
    if Buffer[Len-1]=#0 then
    begin
      break;
    end;
    Result := SeGetDirHd(Channel,false,SesId,FName,Attrib,Buffer[0],length(Buffer),Len);
  end;
  // dopisanie zera gdyby nie by³o
  if Stream.Size>0 then
  begin
    p := pchar(Stream.Memory);
    inc(p,Stream.Size-1);
    if p^<>#0 then
    begin
      a := #0;
      Stream.Write(a,sizeof(a));
    end;
  end
  else
  begin
    a := #0;
    Stream.Write(a,sizeof(a));
  end;
  if Result = stTooMuchRecData then
    Result:= stBufferToSmall;

  if Result=stEND_OFF_DIR then
    Result:= stOK;
end;

function  TDevice.SeGetDir2(Channel : TChannel; SesId : TSesID; FName : pchar; Attrib : byte; var ExBuffer : pchar; GetMemFunc : TGetMemFunc):TStatus;
var
  Stream  : TMemoryStream;
  L       : integer;
begin
  Stream  := TMemoryStream.Create;
  try
    Result := SeGetDirToStream(Channel,SesId,FName,Attrib,Stream);
    if Result=stOK then
    begin
      if Assigned(GetMemFunc) then
      begin
        Result:=stNoMemory;
        L := Stream.Size;
        ExBuffer := pchar(GetMemFunc(L));
        if Assigned(ExBuffer) then
        begin
          Stream.Seek(0,0);
          Stream.Read(ExBuffer^,L);
          Result:=stOK;
        end;
      end;
    end;
  finally
    Stream.Free;
  end;
end;



function  TDevice.SeGetDir(Channel  : TChannel; SesId : TSesID; FName : pchar; Attrib : byte; Buffer:pchar; MaxLen : integer):TStatus;
var
  Stream  : TMemoryStream;
  p       : pchar;
  L       : integer;
begin
  Stream  := TMemoryStream.Create;
  try
    Result := SeGetDirToStream(Channel,SesId,FName,Attrib,Stream);
    if Result=stOK then
    begin
      L := Stream.Size;
      if L>MaxLen then
      begin
        L :=MaxLen;
        Result:= stBufferToSmall;
      end;
      Stream.Read(Buffer^,L);
      p := pchar(Buffer);
      p[L] := #0;
    end;
  finally
    Stream.Free;
  end;
end;


function  TDevice.SeGetDrvList(Channel  : TChannel; SesId : TSesID; DrvList : pchar):TStatus;
var
  Header : TNetQuery;
  buf    : array[0..50] of char;
  L      : integer;
begin
  Header.SeGetDrvList(SesId,GetNewAskNr);
  L := sizeof(buf);
  Result:=SeKonwers(Channel,Header,buf,L,10000);
  if Result=stOk then
  begin
    StrLCopy(DrvList,buf,20);
  end;
end;

function  TDevice.SeShell(Channel:TChannel; SesId : TSesID; Command : pchar; ResultStr : pchar; MaxLen : integer):TStatus;
var
  Header : TNetQuery;
  a      : char;
  Len    : integer;
begin
  Header.SeShell(SesId,GetNewAskNr,Command);
  if MaxLen<>0 then
    Result:=SeKonwers(Channel,Header,ResultStr^,MaxLen,10000)
  else
  begin
    Len:=1;
    Result:=SeKonwers(Channel,Header,a,Len,10000)
  end
end;

function  TDevice.SeGetGuidEx(Channel:TChannel; SesId : TSesID; FileName : pchar; var Guid : TSeGuid):TStatus;
var
  Header : TNetQuery;
  L      : integer;
  G1     : TSeGuid;
begin
  Header.SeGetGuidEx(SesId,GetNewAskNr,FileName);
  L := sizeof(G1);
  Result:=SeKonwers(Channel,Header,G1,L,10000);
  if Result=stOk then
  begin
    if L <> sizeof(G1) then
      Result:=stBadReplay;
  end;
  if Result=stOk then
  begin
    Guid.d1 := DSwap(G1.d1);
    Guid.d2 := DSwap(G1.d2);
  end;
end;

function  TDevice.SeReadFileEx(Channel:TChannel; SesId : TSesID; FileName : pchar; autoclose: boolean; var buf;
          var size: integer; var FileNr: TFileNr):TStatus;
var
  Header : TNetQuery;
  L      : integer;
  Tmp    : array of byte;
  size1  : byte;
begin
  if size>255 then
    size1 := 255
  else
    size1 := size;
  setlength(Tmp,size1+2);

  Header.SeReadFileEx(SesId,GetNewAskNr,FileName,AutoClose,Size1);
  L := size1+2;
  Result:=SeKonwers(Channel,Header,Tmp[0],L,10000);
  if Result=stOk then
  begin
    FileNr := Tmp[0];
    dec(L,2);
    if L>size1 then
      L :=size1;
    move(Tmp[2],buf,L);
    size :=L;
  end;
  setlength(Tmp,0);
end;

function  TDevice.SeReadFileHd(Channel:TChannel; SesId : TSesID;  FileNr : TFileNr; var buf; var Cnt : integer):TStatus;
var
  Header : TNetQuery;
begin
  Header.SeReadFile(SesId,GetNewAskNr,FileNr,Cnt);
  Result:=SeKonwers(Channel,Header,buf,Cnt,10000);
end;

{
function TDevice.SeReadFile(Channel:TChannel; SesId : TSesID;  FileNr : TFileNr; var buf; var Cnt : integer):TStatus;
var
  Cnt1 : integer;
  CntS : integer;
  p    : pByte;
begin
  glProgress  := true;
  glToReadCnt := Cnt;
  glReadSuma  := 0;
  SetProgress(0);
  SetWorkFlag(true);

  p := pByte(@buf);
  CntS := 0;
  Result := stOK;
  while (Result=stOK) and (Cnt<>0) do
  begin
    Cnt1:=Cnt;
    Result := SeReadFileHd(Channel,SesId,FileNr,p^,Cnt1);
    if Result=stOK then
    begin
      dec(Cnt,Cnt1);
      inc(CntS,Cnt1);
      inc(p,cnt1);
    end;
    glReadSuma  := CntS;
    if Cnt1=0 then
      break;
  end;
  Cnt := CntS;
  SetProgress(100);
  SetWorkFlag(false);
  glProgress  := false;
end;
}


function TDevice.SeReadFile(Channel:TChannel; SesId : TSesID;  FileNr : TFileNr; var buf; var Cnt : integer):TStatus;
var
  step : integer;
  CntS : integer;
  p    : pByte;
begin
  glProgress  := true;
  glToReadCnt := Cnt;
  glReadSuma  := 0;
  SetProgress(0);
  SetWorkFlag(true);

  p := pByte(@buf);                             
  CntS := 0;
  Result := stOK;

  {$IFDEF FOR_SLOW_MODEM}
  Step := 8256;
  {$ELSE}
  Step := Cnt;
  {$ENDIF}

  // Rozwiazanie problemu z modemem; Modem: !!!:  przy bardzo wolnej transmisji
  // RZ dzieli wysy³ane dane na rekordy, po wystawieniu ka¿dego rekordu czeka TM (15sek)
  // na przes³anie rekordu,  jeœli modu³ komunikacyjny nie zd¹¿y w tym czasie
  // przes³aæ danych - RZ stwierdzi TimeOut
  // rozwi¹zanie - czytanie mniejszymi paczkami
  // rozmiar 8256 dobrany empirycznie

  while (Result=stOK) and (Cnt>0) do
  begin
    Step := Min(Step,Cnt);
    Result := SeReadFileHd(Channel,SesId,FileNr,p^, Step);
    if Result=stOK then
    begin
      dec(Cnt,Step);
      inc(CntS,Step);
      inc(p,Step);
      inc(glReadSuma,Step);
    end;
    if cnt<=0 then
      break;
    if Step=0 then
      break;
  end;
  Cnt := CntS;
  SetProgress(100);
  SetWorkFlag(false);
  glProgress  := false;
end;


function  TDevice.SeWriteFileHd(Channel:TChannel; SesId : TSesID; FileNr : TFileNr; const buf; var Cnt : integer):TStatus;
var
  Header   : TNetQuery;
  Max      : integer;
  RdBuffer : cardinal;
  RdSize   : integer;
begin
  if cnt>0 then
  begin
    Header.SeWriteFile(SesId,GetNewAskNr,FileNr,Cnt);
    Max := MaxWrTab[Channel]-Header.AskFrameCnt;
    if (Max and $01)<>0 then
      Dec(Max);
    if Cnt>Max then
    begin
      Cnt := Max;
      Header.SeWriteFile(SesId,GetNewAskNr,FileNr,Cnt);
    end;        
    RdSize := sizeof(RdBuffer);
    Result:=SeKonwers(Channel,Header,Buf,Cnt,RdBuffer,Rdsize,10000);
    if Result=stOk then
      Cnt := integer(Dswap(RdBuffer))
    else
      Cnt := 0;
  end
  else
    Result:=stOk;
end;

function  TDevice.SeWriteFile(Channel:TChannel; SesId : TSesID; FileNr : TFileNr; const buf; var Cnt : integer):TStatus;
var
  Cnt1 : integer;
  CntS : integer;
  p    : pByte;
begin
  glProgress  := true;
  glToReadCnt := Cnt;
  glReadSuma  := 0;
  SetProgress(0);
  SetWorkFlag(true);

  p := pByte(@buf);
  CntS := 0;
  repeat
    Cnt1:=Cnt;
    Result := SeWriteFileHd(Channel,SesId,FileNr,p^,Cnt1);
    if Result=stOK then
    begin
      dec(Cnt,Cnt1);
      inc(p,cnt1);
      inc(CntS,Cnt1);
    end;
    glReadSuma  := CntS;
  until (Result<>stOK) or (Cnt<=0);
  Cnt := CntS;
  SetProgress(100);
  SetWorkFlag(false);
  glProgress  := false;
end;

function  TDevice.SeSeek(Channel:TChannel; SesId : TSesID; FileNr : TFileNr; Offset  : integer; Orgin : byte; var Pos : integer):TStatus;
type
  TRepl = packed record
     Pos : cardinal;
     SeekFl : byte;
     Free   : byte;
  end;
var
  Header : TNetQuery;
  L      : integer;
  Repl   : TRepl;
begin
  Header.SeSeek(SesId,GetNewAskNr,FileNr,Offset,Orgin);
  L := sizeof(Repl);
  Result:=SeKonwers(Channel,Header,Repl,L,10000);
  if Result=stOk then
  begin
    Pos := integer(DSwap(Repl.Pos));
  end;    
end;

function  TDevice.SeGetFileSize(Channel:TChannel; SesId : TSesID; FileNr : TFileNr; var FileSize : integer):TStatus;
var
  Header : TNetQuery;
  L      : integer;
  F1     : cardinal;
begin
  Header.SeGetFileSize(SesId,GetNewAskNr,FileNr);
  L := sizeof(F1);
  Result:=SeKonwers(Channel,Header,F1,L,10000);
  if Result=stOk then
  begin
    F1 := DSwap(F1);
    if L <> sizeof(F1) then
      Result:=stBadReplay;
    FileSize := integer(F1);
  end;
end;


function  TDevice.SeCloseFile(Channel:TChannel; SesId : TSesID;  FileNr : TFileNr):TStatus;
var
  Header : TNetQuery;
  Cnt    : integer;
begin
  Cnt:=5;
  repeat
    Header.SeCloseFile(SesId,GetNewAskNr,FileNr);
    Result:=SeKonwers(Channel,Header,10000);
    dec(Cnt);
  until (Cnt=0) or (Result=stOK)
end;

function  TDevice.SeGetGuid(Channel:TChannel; SesId : TSesID;  FileNr : TFileNr; var Guid : TSeGuid):TStatus;
var
  Header : TNetQuery;
  G1     : TSeGuid;
  L      : integer;
begin
  Header.SeGetGuid(SesId,GetNewAskNr,FileNr);
  L := sizeof(G1);
  Result:=SeKonwers(Channel,Header,G1,L,10000);
  if Result=stOk then
  begin
    if L <> sizeof(G1) then
      Result:=stBadReplay;
  end;
  if Result=stOk then
  begin
    Guid.d1 := DSwap(G1.d1);
    Guid.d2 := DSwap(G1.d2);
  end;
end;

function  TDevice.ProtokolAligment : TStatus;
var
  Header: TNetQuery;
  st    : TStatus;
  size  : integer;
begin
  BeckSoftVer := bVer1;
  Header.GetProtokolVersion;
  st := Konwers(chBECK,Header,10000);

  if st=stOK then
  begin
    if Header.Body.QrCmd=#255 then     // jest obs³ugiwana ramka '20'
    begin
      case Header.Body.VarB2 of       // pobranie numeru wersji protoko³u
      2 : BeckSoftVer := bVer2;
      3 : BeckSoftVer := bVer3;
      end;

      if BeckSoftVer >= bVer3 then
      begin
        BeckSoftVer := bVer3;
        Size := DSwap(Header.Body.Adr1);
        if Size>MAX_SENS_SIZE then Size:=MAX_SENS_SIZE;
        MaxWrTab[chBECK] := Size;

        Size := DSwap(Header.Body.Adr2);
        if Size>MAX_SENS_SIZE then Size:=MAX_SENS_SIZE;
        MaxRdTab[chBECK] := Size;

        Header.SetEmulateVer(bVer3);
        Konwers(chBECK,Header,10000);
      end;
    end;
  end;
  Result := st;
end;


procedure TDevice.RegisterCallBackFun(ACallBackFunc : TCallBackFunc; CmmId : integer);
begin
  FCallBackFunc := ACallBackFunc;
  FCmmId := CmmId;
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
  inc(FCurrId,NUM_FOR_CONNECT);
end;

//  TCP;192.168.0.125;8040
function TDevList.AddAcc(ConnectStr : pchar): TAccId;
var
  s     : shortstring;
  p     : integer;
  OkStr : boolean;
  DevItem : TDevice;
  Ip      : string;
  port    : word;
  IpD     : cardinal;
begin
  Result := -1;
  p := 0;
  s := GetTocken(ConnectStr,p);
  if s='RTCP' then
  begin
    Ip := GetTocken(ConnectStr,p);
    OkStr := (StrToInetAdr(Ip,IpD) = stOk);

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


    if OkStr then
    begin
      try
        EnterCriticalSection(FCriSection);
        Devitem := TDevice.Create(Ip,Port);
        DevItem.AccID := GetId;
        DevItem.MyIpD := IpD;
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

function TDevList.FindId(AccId : TAccId; var Channel : TChannel):TDevice;
var
  i : integer;
  T : TDevice;
begin
  Result := nil;
  if AccId>=0 then
  begin
    try
      EnterCriticalSection(FCriSection);
      for i:=0 to Count-1 do
      begin
        T := TDevice(Items[i]);
        if (AccId>=T.AccID) and (AccId<T.AccID+NUM_FOR_CONNECT) then
        begin
          Channel := TChannel(AccId-T.AccID);
          Result := T;
          Break;
        end;
      end;
    finally
      LeaveCriticalSection(FCriSection);
    end;
  end;
end;

function  TDevList.FindId(AccId : TAccId):TDevice;
var
  Channel : TChannel;
begin
  Result := FindId(AccId,Channel);
end;

function  TDevList.FindIp(IPD : cardinal):TDevice;
var
  i : integer;
begin
  Result := nil;
  try
    EnterCriticalSection(FCriSection);
    for i:=0 to Count-1 do
    begin
      if Items[i].MyIpD=IPD then
      begin
        Result := Items[i];
        Break;
      end;
    end;
  finally
    LeaveCriticalSection(FCriSection);
  end;
end;


//  -------------------- Export ---------------------------------------------
procedure LibIdentify(var LibGuid :TGUID); stdcall;
begin
  LibGuid := CommLibGuid;
end;

procedure SetEmulateVer(Ver : integer);
begin
  EmulateVer := Ver;
end;

procedure SetLanguage(LibName : pchar;Language:pchar;ServiceMode:integer); stdcall;
begin
  LanguageList.InitDllMode(LibName,Language,ServiceMode<>0);
end;

function  GetLibProperty:pchar; stdcall;
begin
  case EmulateVer of
  1 : result := pchar(LibPropertyStrV2);
  else
    result := pchar(LibPropertyStr);
  end;
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

function ReadS(Id :TAccId; var S; var Vec : Cardinal): TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.ReadS(Channel,S,Vec)
  else
    Result := stBadId;
end;

function ReadDevInfo(Id :TAccId; var DevInfo :TDevInfo): TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.ReadDevInfo(Channel,DevInfo)
  else
    Result := stBadId;
end;

function ReadReg(Id :TAccId; var  Buffer): TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.ReadReg(Channel,Buffer)
  else
    Result := stBadId;
end;

function ReadMem(Id :TAccId; var Buffer; adr : Cardinal; size : Cardinal): TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.ReadMem(Channel,Buffer,Adr,Size)
  else
    Result := stBadId;
end;


function WriteMem(Id :TAccId; var Buffer; adr : Cardinal; Size : Cardinal): TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.WriteMem(Channel,Buffer,Adr,Size)
  else
    Result := stBadId;
end;

function WriteCtrl(Id :TAccId; nr: byte; b: byte): TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.WriteCtrl(Channel,Nr,b)
  else
    Result := stBadId;
  OutputDebugString(pchar(Format('WriteCtrl: Nr=%u V=0x%2X Result=%u',[nr,b,Result])));
end;

function ReadCtrl(Id :TAccId; nr : byte; var b : byte): TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.ReadCtrl(Channel,Nr,b)
  else
    Result := stBadId;
end;

function  OwnKonwers(Id :TAccId; var Header; var Buffer; var SizeR: integer; SizeW : integer): TStatus; stdcall;
var
  Dev : TDevice;
  Qry : TNetQuery;
begin
  Qry.Body := TBody(Header);
  Qry.AskFrameCnt := 0;
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
    Result := Dev.Konwers(chBECK,Qry,Buffer,SizeW,Buffer,SizeR,10000)
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

function  SeOpenSesion(Id :TAccId; var SesId : TSesID) : TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.SeOpenSesion(Channel,SesId)
  else
    Result := stBadId;
end;

function  SeCloseSesion(Id :TAccId; SesId : TSesID) : TStatus; stdcall;
var
  Dev     : TDevice;
  channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id);
  if Dev<>nil then
  begin
    Channel := TChannel(Id - Dev.AccID);
    Result := Dev.SeCloseSesion(Channel,SesId)
  end
  else
    Result := stBadId;
end;

function  SeOpenFile(Id :TAccId; SesId : TSesID; FName : pchar; Mode : byte; var FileNr : TFileNr):TStatus; stdcall;
var
  Dev     : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.SeOpenFile(Channel,SesId,FName,Mode,FileNr)
  else
    Result := stBadId;
end;

function  SeGetDir(Id :TAccId; SesId : TSesID; FName : pchar; Attrib : byte; Buffer : pchar; MaxLen : integer):TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.SeGetDir(Channel,SesId,FName,Attrib,Buffer,MaxLen)
  else
    Result := stBadId;
end;

function  SeGetDir2(Id :TAccId; SesId : TSesID; FName : pchar; Attrib : byte; var Buffer : pchar; GetMemFunc : TGetMemFunc):TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.SeGetDir2(Channel,SesId,FName,Attrib,Buffer,GetMemFunc)
  else
    Result := stBadId;
end;

function  SeGetDrvList(Id :TAccId; SesId : TSesID; DrvList : pchar):TStatus;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.SeGetDrvList(Channel,SesId,DrvList)
  else
    Result := stBadId;
end;

function  SeShell(Id :TAccId; SesId : TSesID; Command : pchar; ResultStr : pchar; MaxLen : integer):TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.SeShell(Channel,SesId ,Command,ResultStr,MaxLen)
  else
    Result := stBadId;
end;

function  SeReadFile(Id :TAccId; SesId : TSesID;  FileNr : TFileNr; var buf; var Cnt : integer):TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.SeReadFile(Channel,SesId,FileNr,Buf,Cnt)
  else
    Result := stBadId;
end;

function  SeWriteFile(Id :TAccId;  SesId : TSesID; FileNr : TFileNr; const buf; var Cnt : integer):TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.SeWriteFile(Channel,SesId,FileNr,Buf,Cnt)
  else
    Result := stBadId;
end;

function  SeSeek(Id :TAccId;  SesId : TSesID; FileNr : TFileNr; Offset  : integer; Orgin : byte; var Pos : integer):TStatus;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.SeSeek(Channel,SesId,FileNr,Offset,Orgin,Pos)
  else
    Result := stBadId;
end;

function  SeGetFileSize(Id :TAccId;  SesId : TSesID; FileNr : TFileNr; var FileSize : integer):TStatus; stdcall;
var
  Dev     : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.SeGetFileSize(Channel,SesId,FileNr,FileSize)
  else
    Result := stBadId;
end;

function  SeCloseFile(Id :TAccId; SesId : TSesID;  FileNr : TFileNr):TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.SeCloseFile(Channel,SesId,FileNr)
  else
    Result := stBadId;
end;


function  SeGetGuid(Id :TAccId; SesId : TSesID;  FileNr : TFileNr; var Guid : TSeGuid):TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.SeGetGuid(Channel,SesId,FileNr,Guid)
  else
    Result := stBadId;
end;

function  SeGetGuidEx(Id :TAccId; SesId : TSesID; FileName : pchar; var Guid : TSeGuid):TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.SeGetGuidEx(Channel,SesId,FileName,Guid)
  else
    Result := stBadId;
end;

function SeReadFileEx(Id :TAccId; SesId : TSesID; FileName : pchar; autoclose: boolean; var buf;
              var size: integer; var FileNr: TFileNr):TStatus; stdcall;
var
  Dev : TDevice;
  Channel : TChannel;
begin
  Dev := GlobDevList.FindId(Id,Channel);
  if Dev<>nil then
    Result := Dev.SeReadFileEx(Channel,SesId,FileName,autoclose,buf,size,FileNr)
  else
    Result := stBadId;
end;



function  GetErrStr(Id :TAccId; Code :TStatus; S : pChar; Max: integer): boolean;  stdcall;
var
  Dev : TDevice;
  Channel :TChannel;
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
  stSumHeaderError  : strplcopy(S,Lang.Value(TXT007),Max);
  stSumBufError     : strplcopy(S,Lang.Value(TXT008),Max);
  stBadParams       : strplcopy(S,Lang.Value(TXT023),Max);
  stNoMemory        : strplcopy(S,Lang.Value(TXT025),Max);
  stH8Error         : strplcopy(S,Lang.Value(TXT026),Max);

  stTooMuchRecData,
  stBadReplay,
  stBadHostRepl,
  stUnkHostFunct,
  stUnkBeckRepl     : strplcopy(S,Format('%s (%u)',[Lang.Value(TXT009),Code]),Max);

  WSAECONNRESET     : strplcopy(S,Lang.Value(TXT011),Max);
  WSAENOTCONN       : strplcopy(S,Lang.Value(TXT012),Max);
  WSAECONNABORTED   : strplcopy(S,Lang.Value(TXT024),Max);

  else
    result := false;
  end;
  if not(result) then
  begin
    Dev := GlobDevList.FindId(Id,Channel);
    if Dev<>nil then
      Result := Dev.GetErrStr(Channel,code,S,Max);
  end;
  if not(result) then
  begin
    strplcopy(S,Lang.Value(Txt018)+' '+IntToStr(Code),Max);
  end;
end;

function GetApplicationName : string;
var
  StartupInfo : TStartupInfo;
  pch         : pchar;
begin
  GetStartupInfo(StartupInfo);
  pch := pchar(StartupInfo.lpTitle);
  if Assigned(pch) then
  begin
    Result := pch;
    Result := ExtractFileName(Result);
    Result := ChangeFileExt(Result,'');
  end
  else
    Result := '';
end;



initialization
  IsMultiThread := True;  // Make memory manager thread safe
  GlobDevList := TDevList.Create;
  EmulateVer := 0;
  ApplicationName := GetApplicationName;

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
  Lang.AddItem(TXT026,'B³¹d pocesora HOST');
  Lang.AddItem(TXT009,'B³¹d komunikacji' );

finalization
  GlobDevList.Free;


end.
