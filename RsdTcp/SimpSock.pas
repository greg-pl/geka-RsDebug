unit SimpSock;

interface

uses
  Classes,Windows,WinSock, Messages,Types,SysUtils;


const
  wm_SocketEvent = wm_user+100;

type
  TStatus = integer;

const
  stOk          =  0;
  stNotOpen     = 12;
  stUserBreak   = 15;
  stFrmTooLarge = 16;
  stError       = -1;

type
  TRdEvent = procedure(Sender:TObject; RecBuf:string;RecIp:string;RecPort:word) of object;
  TMsgFlow = procedure(Sender:TObject; R: real) of object;

  TSockCheckMthd = function(
    const aTimeVal : TTimeVal;
    const aFdSet : TFdSet): Integer of object;

  TSimpSock = class(TObject)
  private
    fSd : TSocket;
    FMsgFlow : TMsgFlow;
    FRecWaitTime : integer;
    procedure WndProc(var AMessage: TMessage);
    procedure SetMsgFlow(R : real);
    procedure SetRecWaitTime(Value: Integer);
  protected
    FOwnHandle : THandle;
    FLastErr   : integer;
    FPort      : word;
    FIp        : string;
    BreakFlag  : boolean;
    FActive    : boolean;
    function  LoadLastErr(Res: TStatus):TStatus;
    function  ProcessMes(var AMessage: TMessage): boolean; virtual;
    function  FillINetStruct(var Addr :sockaddr_in; IP : string; Port: word): TStatus; overload;
    function  FillINetStruct(var Addr :sockaddr_in; IPd: cardinal; Port: word):TStatus; overload;

    property Sd: TSocket read fSd write fSd;

  public
    ExceptCnt  : integer;
    //RecWaitTime : integer;
    SndWaitTime : integer;
    constructor Create;
    destructor Destroy; override;
    function  Open :TStatus; virtual;
    function  Close: TStatus; virtual;
    procedure SetBreak(val: boolean);
    function  GetHandle : Thandle;
    procedure Freehandle;
    function SockCheck(const aCheckMthd: TSockCheckMthd): Boolean;
    function SockCheckRead(const aTimeVal : TTimeVal;
      const aFdSet : TFdSet): Integer; //inline;
    function SockCheckWrite(const aTimeVal : TTimeVal;
      const aFdSet : TFdSet): Integer; //inline;
    function SockCheckExcept(const aTimeVal : TTimeVal;
      const aFdSet : TFdSet): Integer; //inline;
    function  CheckRead: boolean; //inline;
    function  CheckWrite: boolean; //inline;
    function  CheckExcept: boolean; //inline;
    property  LastErr: integer read FLastErr;
    property  Port: word read FPort write FPort;
    property  Ip: string read FIp write FIp;
    function  DSwap(X : Cardinal):cardinal;
    property  MsgFlow : TMsgFlow read FMsgFlow write FMsgFlow;
    property  Socket : TSocket read fSd;
    property Active: Boolean read FActive write FActive;
    property RecWaitTime : integer read FRecWaitTime write SetRecWaitTime;
  end;

  TSimpUdp = class(TSimpSock)
  private
    FOnMsgRead  : TRdEvent;
    FAsync      : boolean;
    procedure FSetAsync(AAsync : boolean);
    function  FGetAsync: boolean;
  protected
    RecBuf  : string;
    RecIp   : string;
    RecPort : word;
    procedure DoOnMsgRead; virtual;
    function  ProcessMes(var AMessage: TMessage): boolean; override;
  public
    VPort   : word;
    constructor Create;
    function Open : TStatus; override;
    function Close: TStatus; override;
    function ReadFromSocket(var RecBuf: string; var RecIp :string; var RecPort : word):TStatus;
    function SendBuf(DestIp : string; DestPort: word; var buf; Len : integer):TStatus;  overload;
    function SendBuf(DestIp : Cardinal; DestPort: word; var buf; Len : integer):TStatus; overload;
    function SendStr(DestIp : string; DestPort: word; ToSnd : string):TStatus; overload;
    function SendStr(IpD : cardinal; DestPort: word; ToSnd : string):TStatus; overload;
    function BrodcastStr(DestPort: word; ToSnd : string):TStatus;
    function ClearRecBuf:TStatus;
    function EnableBrodcast(Enable: boolean):TStatus;
    property OnMsgRead : TRdEvent read FOnMsgRead  write FOnMsgRead;
    property Async : boolean read FGetAsync write FSetAsync;
  end;

  TSimpTcp=class(TSimpSock)
  private
    MaxRecBuf : integer;
    MaxSndBuf : integer;
    fLastReceiveOK: Cardinal;
  protected
  public
    constructor Create;
    function Open : TStatus; override;
    function Close: TStatus; override;
    function Connect: TStatus; virtual;
    function ReOpen : TStatus;
    function Write(Var buf; Len : integer): TStatus;
    function WriteStream(Stream : TMemoryStream): TStatus;
    //ReadStream: MaxBytes: zabezpieczenie przed allokacj¹ zbyt wielkich bloków pamiêci
    //MaxTimeMsec : Maksymalny okres oczekiwania na kompletacjê danych
    function ReadStream(Stream : TMemoryStream; MaxBytes : Integer): TStatus;
    function ReadBinaryStream(Stream : TMemoryStream; MaxBytes : Integer): TStatus;
    function ReciveToBufTime(StartT: Cardinal;var Buf; Count : integer): TStatus;
    function Read(Var buf; var Len : integer): TStatus;
    function ClearInpBuf:TStatus;
    function GetLastReceiveOK(): Cardinal;
  end;

function StrToInetAdr(Ip : string; var IpD : Cardinal): TStatus;
function DSwap(X : Cardinal):cardinal;
function IpToStr(Ip : cardinal):string;
procedure GetLocalAdresses(SL :TStrings);
function GetLocalAdress : string;
function GetHostName: string;


var
  SocketsVersion : integer;
  SocketRevision : integer;
  SocketsOk      : boolean;

implementation

function StrToIP(S : string;var Ip : cardinal): boolean;
var
  a       : integer;
  b       : array[0..3] of cardinal;
  err     : boolean;
  x,k,i,l : integer;
  s1      : string;
begin
  l := length(s);
  i:=1;
  err:=false;
  for k:=0 to 3 do
  begin
    x :=i;
    while (i<=l) and (s[i]<>'.') do inc(i);
    s1 := copy(s,x,i-x);
    inc(i);
    if s1<>'' then
    begin
      try
        a:=StrToInt(s1);
        if (a>255) or (a<0) then
          Err:=False
        else
          b[k]:=a;
      except
        err:=true;
      end;
    end
    else
      Err:=true;
  end;
  if not(Err) then
  begin
    Ip := (b[3] shl 24) or (b[2] shl 16) or (b[1] shl 8) or b[0];
  end;
  Result := not(Err);
end;

function  DSwap(X : Cardinal):cardinal;
begin
  Result := Swap(X shr 16) or (Swap(x and $ffff) shl 16);
end;

function IpToStr(Ip : cardinal):string;
var
  b1,b2,b3,b4 : byte;
begin
  Ip := DSwap(Ip);
  b1 := (Ip shr 24) and $ff;
  b2 := (Ip shr 16) and $ff;
  b3 := (Ip shr 8) and $ff;
  b4 := Ip and $ff;
  Result := Format('%u.%u.%u.%u',[b1,b2,b3,b4]);
end;
function GetHostName: string;
begin
  SetLength(result, 250);
  WinSock.GetHostName(PChar(result), Length(result));
  Result := String(PChar(result));
end;

procedure GetLocalAdresses(SL :TStrings);
type
  TaPInAddr = Array[0..250] of PInAddr;
  PaPInAddr = ^TaPInAddr;
var
  i: integer;
  AHost: PHostEnt;
  PAdrPtr: PaPInAddr;
begin
  SL.Clear ;
  AHost := GetHostByName(PChar(GetHostName));
  if AHost <> nil then
  begin
    PAdrPtr := PAPInAddr(AHost^.h_addr_list);
    i := 0;
    while PAdrPtr^[i] <> nil do
    begin
      SL.Add(IpToStr(cardinal(PAdrPtr^[i].S_addr)));
      Inc(i);
    end;
  end;
end;

function  GetLocalAdress : string;
var
  SL :TStringList;
begin
  Result := '';
  SL := TStringList.Create;
  try
    GetLocalAdresses(SL);
    if SL.Count>0 then
      Result := SL.Strings[0];
  finally
    SL.Free;
  end;
end;

function StrToInetAdr(Ip : string; var IpD : cardinal): TStatus;
begin
  if Ip<>'' then
  begin
    if not(StrToIP(Ip,IpD)) then
    begin
      WinSock.WSASetLastError(WSAEFAULT);
      Result:=WSAEFAULT;
    end
    else
      Result:=stOk;
  end
  else
  begin
    IpD := 0;
    Result := stOk;
  end;
end;


// -------------------------- TSimpSock ----------------------------------

constructor TSimpSock.Create;
begin
  inherited Create;
  Sd:= INVALID_SOCKET;
  FownHandle := INVALID_HANDLE_VALUE;
  FPort := 0;
  FIp   := '';
  ExceptCnt:=0;
  RecWaitTime  := 200;   // 200 milisekund
  SndWaitTime  := 200;   // 200 milisekund
  FActive := True;
end;

function  TSimpSock.LoadLastErr(Res: TStatus):TStatus;
begin
  if (Res <> stOk) then
    FLastErr := WSAGetLastError
  else
    FLastErr := stOk;
  Result := FLastErr
end;

function TSimpSock.Open : TStatus;
begin
  Result := stOk;
  if Sd <> INVALID_SOCKET then
  begin
    Result := Close;
  end;
end;

function TSimpSock.Close: TStatus;
begin
  result := WinSock.shutdown(Sd, SD_Send);
  if Result=stOk then
    result := WinSock.CloseSocket(Sd);
  if Result=stOk then
    Sd := INVALID_SOCKET;
  Result := LoadLastErr(Result);
end;

destructor TSimpSock.Destroy;
begin
  FreeHandle;
  inherited;
end;

procedure TSimpSock.SetBreak(val: boolean);
begin
  BreakFlag := Val;
end;

function  TSimpSock.GetHandle : Thandle;
begin
  if FOwnHandle=INVALID_HANDLE_VALUE then
  begin
    FownHandle:= Classes.AllocateHWnd(WndProc);
  end;
  Result := FOwnHandle;
end;

procedure TSimpSock.Freehandle;
begin
  if FOwnHandle<>INVALID_HANDLE_VALUE then
  begin
    Classes.DeallocateHWnd(FownHandle);
  end;
end;

procedure TSimpSock.SetMsgFlow(R : real);
begin
  if Assigned(FMsgFlow) then FMsgFlow(self,R);
end;


procedure TSimpSock.WndProc(var AMessage: TMessage);
var
  p : boolean;
begin
  inherited;
  try
    p:=ProcessMes(AMessage);
  except
    inc(ExceptCnt);
    p := false;
  end;
  if not(p) then
    AMessage.Result := DefWindowProc(FOwnHandle, AMessage.Msg, AMessage.wParam, AMessage.lParam);
end;

function  TSimpSock.ProcessMes(var AMessage: TMessage): boolean;
begin
  Result := False;
end;

function TSimpSock.CheckRead: boolean;
begin
  Result:= SockCheck(SockCheckRead)
end;

function TSimpSock.CheckWrite: boolean;
begin
  Result:= SockCheck(SockCheckWrite)
end;

function TSimpSock.FillINetStruct(var Addr :sockaddr_in; IP : string; Port: word):TStatus;
var
  Ipd : cardinal;
begin
  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sin_family        := PF_INET;
  Addr.sin_port          := WinSock.HToNs(Port);
  Result := StrToInetAdr(Ip,IpD);
  Addr.sin_addr.S_addr := integer(IpD);
end;

function TSimpSock.FillINetStruct(var Addr :sockaddr_in; IPd: cardinal; Port: word):TStatus;
begin
  FillChar(Addr, SizeOf(Addr), 0);
  Addr.sin_family        := PF_INET;
  Addr.sin_port          := WinSock.HToNs(Port);
  Addr.sin_addr.S_addr   := integer(Ipd);
  Result := stok;
end;

function TSimpSock.DSwap(X : Cardinal):cardinal;
begin
  Result := Swap(X shr 16) or (Swap(x and $ffff) shl 16);
end;

// -------------------------- TSimpUdp ----------------------------------

constructor TSimpUdp.Create;
begin
  inherited Create;
  RecWaitTime  := 200;   // 200 milisekund
  SndWaitTime  := 200;   // 200 milisekund
  FAsync   := false;
end;

function TSimpUdp.Open : TStatus;
var
  N       : integer;
  LAddr   : sockaddr_in;
  Addr    : sockaddr_in;
begin
  Result := inherited Open;
  if Result=stOk then
  begin
    Sd := WinSock.Socket(AF_INET,SOCK_DGRAM,IPPROTO_IP);
    if Sd=INVALID_SOCKET then
      Result := WSAGetLastError;
  end;
  EnableBrodcast(True);
  if Result=stOk then
    Result := FillINetStruct(Addr,FIp,FPort);
  if Result=stOk then
  begin
    Result := WinSock.bind(Sd,addr, SizeOf(Addr));
  end;
  if Result=stOk then
  begin
    n := SizeOf(LAddr);
    Result:= GetSockName(Sd, LAddr, n);
  end;

  if Result=stOk then
  begin
    VPort := Ntohs(LAddr.sin_port);
    FSetAsync(True);
  end;
  Result:=LoadLastErr(Result);
end;

function TSimpUdp.Close: TStatus;
begin
  FSetAsync(False);
  Result := inherited Close;
end;

function TSimpUdp.EnableBrodcast(Enable: boolean): TStatus;
var
  State : integer;
begin
  if Enable then
    State:=1
  else
    State:=0;
  Result := setsockopt(Sd,SOL_SOCKET,SO_BROADCAST,@State,sizeof(State));
  Result:=LoadLastErr(Result);
end;

function TSimpUdp.SendBuf(DestIp : string; DestPort: word; var buf; Len : integer):TStatus;
var
  Addr    : sockaddr_in;
begin
  Result := FillINetStruct(Addr,DestIp,DestPort);
  if Result=stOk then
    Result:=WinSock.sendto(Sd,buf,len,0,Addr,sizeof(Addr));
  Result:=LoadLastErr(Result);
end;

function TSimpUdp.SendBuf(DestIp : Cardinal; DestPort: word; var buf; Len : integer):TStatus;
var
  Addr    : sockaddr_in;
begin
  Result := FillINetStruct(Addr,DestIp,DestPort);
  if Result=stOk then
    Result:=WinSock.sendto(Sd,buf,len,0,Addr,sizeof(Addr));
  Result:=LoadLastErr(Result);
end;

function TSimpUdp.SendStr(DestIp : string; DestPort: word; ToSnd : string):TStatus;
begin
  if ToSnd<>'' then
    Result := SendBuf(DestIp,DestPort,ToSnd[1],Length(ToSnd))
  else
    Result := stOk;
end;

function TSimpUdp.SendStr(IpD : cardinal; DestPort: word; ToSnd : string):TStatus;
begin
  if ToSnd<>'' then
    Result := SendBuf(IpD,DestPort,ToSnd[1],Length(ToSnd))
  else
    Result := stOk;
end;

function TSimpUdp.BrodcastStr(DestPort: word; ToSnd : string):TStatus;
begin
  Result := SendStr('255.255.255.255',DestPort,ToSnd);
end;


function TSimpUdp.ClearRecBuf:TStatus;
var
  AddrSize: integer;
  RecAdr  : sockaddr_in;
  Len     : u_long;
  st      : integer;
  RecBuf  : string;
begin
  repeat
    st:= ioctlsocket(Sd,FIONREAD,len);
    if st<>SOCKET_ERROR then
    begin
      if Len<>0 then
      begin
        SetLength(RecBuf,Len+1);
        AddrSize := SizeOf(RecAdr);
        st:=WinSock.recvfrom(Sd,RecBuf[1],length(RecBuf),0,RecAdr,AddrSize);
      end;
    end;
  until (st=SOCKET_ERROR) or (Len=0);
  result := st;
end;



function TSimpUdp.ReadFromSocket(var RecBuf: string; var RecIp :string; var RecPort:word):TStatus;
var
  AddrSize: integer;
  RecAdr  : sockaddr_in;
  Len     : u_long;
  L       : integer;
begin
  L := 0;
  result := ioctlsocket(Sd,FIONREAD,len);
  if Result=stOk then
  begin
    if Len<>0 then
    begin
      SetLength(RecBuf,Len+1);
      AddrSize := SizeOf(RecAdr);
      L:=WinSock.recvfrom(Sd,RecBuf[1],length(RecBuf),0,RecAdr,AddrSize);
      if L=SOCKET_ERROR then
      Result := WSAGetLastError;
    end;
  end;
  if Result=stOk then
  begin
    if L<>0 then
    begin
      Setlength(RecBuf,L);
      recIp := WinSock.inet_ntoa(RecAdr.sin_addr);
      RecPort := WinSock.HToNs(RecAdr.sin_port);
    end
    else
    begin
      RecBuf := '';
      recIp := '';
      RecPort := 0;
    end;
    FLastErr := 0;
  end;
  LoadLastErr(Result);
end;

procedure TSimpUdp.FSetAsync(AAsync : boolean);
var
  p: TStatus;
begin
  p := stOk;
  if AAsync then
  begin
    if not(FAsync) then
    begin
      GetHandle;
      p :=WSAAsyncSelect(Sd,FownHandle,wm_SocketEvent,FD_READ);
    end;
  end
  else
  begin
    if FAsync then
    begin
      p :=WSAAsyncSelect(Sd,FownHandle,0,0);
    end;
  end;
  FAsync:=AAsync;
  LoadLastErr(p);
end;

function  TSimpUdp.FGetAsync: boolean;
begin
  Result := (FownHandle<>INVALID_HANDLE_VALUE);
end;

function  TSimpUdp.ProcessMes(var AMessage: TMessage): boolean;
var
  Ev  : word;
begin
  result := inherited ProcessMes(AMessage);
  if AMessage.Msg = wm_SocketEvent then
  begin
    Ev := LoWord(AMessage.LParam);
    if (Ev and FD_READ) <>0 then
       DoOnMsgRead;
    Result := True;
  end;
end;


procedure TSimpUdp.DoOnMsgRead;
begin
  ReadFromSocket(RecBuf,RecIp,RecPort);
  if Assigned(FOnMsgRead) then FOnMsgRead(self,RecBuf,RecIp,RecPort);
end;

//  ------------------------- TSimpTCP -------------------------------------
constructor TSimpTcp.Create;
begin
  inherited Create;
  RecWaitTime  := 3000;   // 200 milisekund
  SndWaitTime  := 3000;   // 200 milisekund
  fLastReceiveOK := 0;
end;

function TSimpTcp.GetLastReceiveOK: Cardinal;
begin
  Result := fLastReceiveOK;
end;

function TSimpTcp.Open : TStatus;
var
  N       : integer;
  S       : integer;
  Size    : integer;
begin
  Result := inherited Open;
  Sd := WinSock.Socket(AF_INET,SOCK_STREAM,IPPROTO_IP);
  if Result<>INVALID_SOCKET then
  begin
    S :=1;   //0-bloking mode;  1-nonbloking mode;
    Result := ioctlsocket(Sd,FIONBIO,S);
  end;
  if Result=stOk then
  begin
    Size := $20100;
    Result:= setSockOpt(Sd,SOL_SOCKET,SO_RCVBUF,Pchar(@Size),sizeof(Size));
  end;
  if Result=stOk then
  begin
    N := sizeof(MaxRecBuf);
    Result:= GetSockOpt(Sd,SOL_SOCKET,SO_RCVBUF,Pchar(@MaxRecBuf),N);
  end;
  if Result=stOk then
  begin
    Size := $20100;
    Result:= setSockOpt(Sd,SOL_SOCKET,SO_SNDBUF,Pchar(@Size),sizeof(Size));
  end;
  if Result=stOk then
  begin
    N := sizeof(MaxSndBuf);
    Result:= GetSockOpt(Sd,SOL_SOCKET,SO_SNDBUF,Pchar(@MaxSndBuf),N);
  end;
  Result := LoadLastErr(Result);
end;

function TSimpTcp.Close: TStatus;
begin
  WinSock.shutdown(Sd, SD_Send);
  result := WinSock.CloseSocket(Sd);
  Sd := INVALID_SOCKET;
  Result := LoadLastErr(Result);
end;

function TSimpTcp.Connect: TStatus;
var
  Addr :sockaddr_in;
begin
  Result:= stError;
  if FillINetStruct(Addr,FIp,FPort) = stOK then
  begin
    // socket is non-blocking (connection attempt cannot be completed immediately)
    // so there will be error on connect
      {Result := }WinSock.connect(Sd,addr, SizeOf(Addr));
    if CheckWrite() then
      Result := stOk
  end
end;

function TSimpTcp.ReOpen : TStatus;
begin
  Close;
  Result := Open;
  if Result=stOk then
    Result := Connect;
end;

function TSimpTcp.Write(Var buf; Len : integer): TStatus;
begin
  Result := WinSock.send(Sd,buf,len,0);
  SetMsgFlow(len);
  Result := LoadLastErr(Result);
end;

function TSimpTcp.WriteStream(Stream : TMemoryStream): TStatus;
begin
  Result := Write(pByte(Stream.memory)^,Stream.Size);
end;

function TSimpTcp.Read(Var buf; var Len : integer): TStatus;
var
  L : integer;
begin
  L := WinSock.recv(Sd, buf,len,0);
  if L<>SOCKET_ERROR then
  begin
    Len := L;
    fLastReceiveOK := GetTickCount();
    Result:=stOk;
  end
  else
  begin
    Result:=WSAGetLastError;
  end;
  Result :=LoadLastErr(Result);
end;


function TSimpTcp.ClearInpBuf:TStatus;
var
  buf  : array of byte;
  L    : integer;
begin
  repeat
    Result := ioctlsocket(Sd,FIONREAD,L);
    if (Result=stOk) and (L>0) then
    begin
      SetLength(buf,L);
      Result:=Read(buf[0],L);
    end;
  until (Result<>stOk) or (L=0);
  Result :=LoadLastErr(Result);
end;

function TSimpTcp.ReciveToBufTime(StartT: Cardinal;var Buf; Count : integer): TStatus;
type
  TByteArray = array[0..MAXINT-1] of byte;
var
  L    : integer;
  Done : boolean;
  Ptr  : integer;
  Size : integer;
begin
  Ptr  := 0;
  Size := Count;
  BreakFlag := false;
  SetMsgFlow(0);
  repeat
    Result := ioctlsocket(Sd,FIONREAD,L);
    if L>0 then
    begin
      if L>Count then L:=Count;
      Result:=Read(TByteArray(buf)[ptr],L);
      Count:=Count-L;
      ptr:=ptr+L;
      SetMsgFlow(Size-Count);
      StartT := GetTickCount;
    end
    else
     sleep(5);
    Done := (Count=0);
  until (integer(GetTickCount-StartT)>RecWaitTime) or (Result<>stOk) or Done or BreakFlag or not FActive;
  if (BreakFlag) or (not FActive) then
  begin
    Result := stUserBreak;
    Exit;
  end;
  if not(Done) then
  begin
    WSASetLastError(WSAETIMEDOUT);      //WSAEMSGSIZE
    Result :=LoadLastErr(WSAETIMEDOUT);
  end else
    fLastReceiveOK := GetTickCount();
end;


function TSimptcp.ReadStream(Stream : TMemoryStream; MaxBytes : Integer): TStatus;
var FrameSize  : DWORD;   //Wielkoœæ ramki
    Count      : Integer; //
    P,Buf : PChar;
begin
  Count := SizeOf(FrameSize);
  result := ReciveToBufTime(GetTickCount,FrameSize, Count);
  if Result<>stOk then
     exit;
  FRameSize := DSwap(FrameSize);//-SizeOf(DWORD);

  if FrameSize > Cardinal(MaxBytes) then
  begin
    result := stFrmTooLarge;
    exit;
  end;

  GetMem(Buf,FrameSize+1);
  P := Buf;
  result := ReciveToBufTime(GetTickCount, P^, FrameSize);
  if result=stOk then
  begin
    inc(p,FrameSize); Byte(P^) := 0;
    Stream.SetSize(FrameSize+1);
    Stream.Seek(0,soFromBeginning);
    Stream.WriteBuffer(Buf^, FrameSize+1);
  end;

  if Buf<>nil then
     FreeMem(Buf);
end;


function TSimptcp.ReadBinaryStream(Stream : TMemoryStream; MaxBytes : Integer): TStatus;
var FrameSize  : DWORD;   //Wielkoœæ ramki
    Count      : Integer; //
    P,Buf : PChar;
begin
  Count := SizeOf(FrameSize);
  result := ReciveToBufTime(GetTickCount,FrameSize, Count);
  if Result<>stOk then
     exit;
  FRameSize := DSwap(FrameSize);//-SizeOf(DWORD);

  if FrameSize > Cardinal(MaxBytes) then
  begin
    result := stFrmTooLarge;
    exit;
  end;

  GetMem(Buf,FrameSize+1);
  P := Buf;
  result := ReciveToBufTime(GetTickCount, P^, FrameSize);
  if result=stOk then
  begin
    Stream.SetSize(FrameSize);
    Stream.Seek(0,soFromBeginning);
    Stream.WriteBuffer(Buf^, FrameSize);
  end;

  if Buf<>nil then
     FreeMem(Buf);
end;

//  ------------------------- inicjalizacja WSA --------------------------------

procedure InitSockets;
var
  sData: TWSAData;
begin
  if WSAStartup($101, sData)<>SOCKET_ERROR then
  begin
    SocketsVersion := sData.wVersion;
    SocketRevision := sData.wHighVersion;
    SocketsOk      := true;
  end
  else
  begin
    SocketsOk      := False;
  end;
end;

procedure DoneSockets;
begin
  WSACleanup;
end;

procedure TSimpSock.SetRecWaitTime(Value: Integer);
begin
   FRecWaitTime := Value;
end;

function TSimpSock.SockCheck(const aCheckMthd: TSockCheckMthd): Boolean;
const
  SOCKET_COUNT = 1;
var
  FdSet: TFDSet;
  TimeVal : TTimeVal;
begin
  Result := false;
  Assert(FD_SETSIZE >= SOCKET_COUNT);
  FdSet.fd_array[0]:= fSd;
  FdSet.fd_count:= SOCKET_COUNT;
  TimeVal.tv_sec  := RecWaitTime div 1000;
  TimeVal.tv_usec := (RecWaitTime * 1000) mod 1000000;
  case aCheckMthd(TimeVal, FdSet) of
    0: // timeout
      FLastErr:= WSAETIMEDOUT;
    SOCKET_ERROR:
      LoadLastErr(SOCKET_ERROR);
    1..FD_SETSIZE:
      Result:= FdSet.fd_count = SOCKET_COUNT
  else
    Assert(false, 'TSimpSock.SockCheck()')
  end
end;

function TSimpSock.SockCheckExcept(const aTimeVal : TTimeVal;
  const aFdSet : TFdSet): Integer;
begin
  Result:= WinSock.select(0, nil, nil, @aFdSet, @aTimeVal)
end;

function TSimpSock.SockCheckRead(const aTimeVal : TTimeVal;
  const aFdSet : TFdSet): Integer;
begin
  Result:= WinSock.select(0, @aFdSet, nil, nil, @aTimeVal)
end;

function TSimpSock.SockCheckWrite(const aTimeVal : TTimeVal;
  const aFdSet : TFdSet): Integer;
begin
  Result:= WinSock.select(0, nil, @aFdSet, nil, @aTimeVal)
end;

function TSimpSock.CheckExcept: boolean;
begin
  Result:= SockCheck(SockCheckExcept)
end;

initialization
  InitSockets;
finalization
  DoneSockets;
end.


