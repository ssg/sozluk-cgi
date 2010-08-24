unit common;

interface

uses

  SysUtils,Windows;

const

  dictfile          = 'dict.txt';
  tempFile          = 'temp.txt';
  backupFile        = 'dict.bak';
  showTemplateFile  = 'show.txt';
  addTemplateFile   = 'add.txt';
  indexTemplateFile = 'index.txt';
  maintTemplateFile = 'maint.txt';
  userFile          = 'user.txt';

  CGIPost           : boolean = false;
  QueryString       : string = '';

function getenv(s:string):string;
function Replace(s,src,dst:string):string;
function HexToInt(s:string; var value:integer):boolean;
function GetParse(s:string; parsechar:char; index:integer):string;
function GetParseCount(s:string; parsechar:char):integer;
function Translate(s,src,dst:string):string;

function getValue(s:string):string;
function isValue(s:string):boolean;

function GetUserPass(username:string):string;

procedure debug(s:string);
procedure normalizeQueryString(var s:string);
procedure normalizeword(var s:string);

procedure outFile(afile:string);

implementation

procedure outFile;
var
  s:string;
  F:Textfile;
begin
  Assign(F,afile);
  Reset(F);
  while not Eof(F) do begin
    readlN(f,s);
    writeln(s);
  end;
  CloseFile(F);
end;

procedure Init;
var
  si:TStartupInfo;
  len:longword;
begin

  QueryString := getenv('QUERY_STRING');
  if QueryString = '' then begin
    len := StrToIntDef(getenv('CONTENT_LENGTH'),0);
    if len > 0 then begin
      GetStartupInfo(si);
      setlength(QueryString,len);
      CGIPost := ReadFile(si.hStdInput,QueryString[1],len,len,NIL);
    end;
  end;
  normalizeQueryString(QueryString);
  writeln('Content-type: text/html'#13#10);
end;

function getValue;
var
  n:integer;
  sub:string;
begin
  s := LowerCase(s);
  Result := '';
  for n:=1 to GetParseCount(QueryString,'&') do begin
    sub := getParse(QueryString,'&',n);
    if LowerCase(GetParse(sub,'=',1)) = s then begin
      Result := GetParse(sub,'=',2);
      exit;
    end;
  end;
end;

function isValue;
var
  n:integer;
  sub:string;
begin
  s := LowerCase(s);
  Result := false;
  for n:=1 to GetParseCount(QueryString,'&') do begin
    sub := getParse(QueryString,'&',n);
    if LowerCase(GetParse(sub,'&',1)) = s then begin
      Result := true;
      exit;
    end;
  end;
end;

function GetUserPass;
var
  F:TextFile;
  s:string;
begin
  AssignFile(F,userFile);
  Reset(F);
  if IOResult = 0 then while not Eof(F) do begin
    Readln(F,s);
    if s <> '' then if s[1] = '~' then begin
      if Trim(copy(s,2,length(s))) = username then begin
        Readln(F,s);
        Result := Trim(s);
        CloseFile(F);
        exit;
      end;
    end;
  end;
  CloseFile(F);
  Result := '';
end;

procedure normalizeword(var s:string);
var
  n:integer;
begin
  s := Translate(s,'$ðüþiöçÐÜÞÝÖÇ','sgusiocGUSiOC');
  for n:=1 to length(s) do
    if not (s[n] in ['0'..'9','A'..'Z','a'..'z']) then s[n] := ' ';
  s := Lowercase(Trim(s));
end;

procedure normalizeQueryString(var s:string);
var
  n:integer;
  b:integer;
begin
  repeat
    n := pos('%',s);
    if n = 0 then break;
    if HexToInt(copy(s,n+1,2),b) then begin
      Delete(s,n,3);
      Insert(char(b),s,n);
    end else s[n] := #255;
  until false;

  s := Replace(s,'<','&lt;');
  s := Replace(s,'>','&gt;');
  s := Translate(LowerCase(Trim(s)),'+'#255,' %');
end;

function Translate;
var
  n,b:integer;
begin
  for n:=1 to length(s) do begin
    b := pos(s[n],src);
    if b > 0 then s[n] := dst[b];
  end;
  Result := s;
end;

function GetParseCount(s:string; parsechar:char):integer;
var
  n:integer;
begin
  Result := 1;
  for n:=1 to length(s) do if s[n]=parsechar then inc(Result);
end;

function GetParse(s:string; parsechar:char; index:integer):string;
var
  n,count:integer;
begin
  count := 0;
  Result := '';
  repeat
    n := pos(parsechar,s);
    if n > 0 then begin
      inc(count);
      if count=index then begin
        Result := Trim(copy(s,1,n-1));
        exit;
      end;
      s := copy(s,n+1,length(s));
      if s = '' then exit;
    end;
  until n=0;
  if count+1 = index then Result := Trim(s);
end;

function HexToInt;
var
  n,t:integer;
  c:char;
begin
  value := 0;
  t := 0;      
  for n:=length(s) downto 1 do begin
    c := upcase(s[n]);
    case c of
      '0'..'9' : t := byte(c)-48;
      'A'..'F' : t := (byte(c)-65)+10;
      else begin
        Result := false;
        exit;
      end;
    end; {case}
    value := value or (t shl ((length(s)-n)*4));
  end;
  Result := true;
end;

procedure debug(s:string);
begin
  writeln(s+'<br>');
  flush(output);
end;

function Replace(s,src,dst:string):string;
var
  b:byte;
begin
  repeat
    b := pos(src,s);
    if b > 0 then begin
      Delete(s,b,length(src));
      if dst <> '' then Insert(dst,s,b);
    end;
  until b = 0;
  Result := s;
end;

function getenv(s:string):string;
var
  ar:array[1..32768] of char;
begin
  FillChar(ar,SizeOf(ar),0);
  GetEnvironmentVariable(PChar(s),@ar,SizeOf(ar));
  Result := Trim(StrPas(@ar));
end;

initialization
begin
  Init;
end;

end.