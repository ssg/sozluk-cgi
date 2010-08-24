program sendmail;

uses

  SysUtils, Windows, WinSock, common;

var
  mFrom,mTo,mSubj,mSMTP,mBody,mReturn:string;
  full:string;
  W:TWSAData;
  mysock:TSocket;
  T:TSockAddrIn;
  ar:array[1..256] of char;
  len:longword;
  F:TextFile;
  s:string;
  procedure waitResponse;
  var
    s:string;
    c:char;
  begin
    c := #0;
    s := '';
    while c <> #10 do begin
      if recv(mysock,c,1,0) > 0 then s := s + c else begin
        outFile('mailfail.txt');
        halt(1);
      end;
    end;
  end;
  procedure doit(s:string);
  begin
    s := s + #13#10;
    len := length(s);
    send(mysock,s[1],len,0);
    waitResponse;
  end;
begin
  mFrom := getValue('from');
  mTo := getValue('to');
  mSubj := getValue('subject');
  mSMTP := getValue('smtp');
  mBody := getValue('body');
  mReturn := getValue('return');

  WSAStartup($101, W);

  mysock := socket(AF_INET,SOCK_STREAM,IPPROTO_TCP);
  if mysock = INVALID_SOCKET then begin
    outFile('mailfail.txt');
    exit;
  end;

  T.sin_family := PF_INET;
  T.sin_addr.s_addr := inet_addr(strpcopy(@ar,mSMTP));
  T.sin_port := htons(25);

  if connect(mysock, T, SizeOf(T)) = 0 then begin
    waitResponse;
    doit('HELO sourtimes');
    doit('MAIL FROM: '+mFrom);
    doit('RCPT TO: '+mTo);
    doit('DATA');
    doit('Subject: '+mSubj+#13#10+
         'X-Mailer: SourTimes Atraksiyonlu CGI Mail Gondericisi v0.1 - (c) SSG ''99'#13#10+
         #13#10+mBody+#13#10#13#10+'.'#13#10);
    doit(#13#10'QUIT');
    
    closesocket(mysock);

  end;

  WSACleanup;
  AssignFile(F,'mailsuc.txt');
  Reset(F);
  while not Eof(F) do begin
    Readln(F,s);
    s := Replace(s,'%return',mReturn);
    writeln(s);
  end;
  CloseFile(F);
end.                                  
