uses

  Common, SysUtils, Windows;

var
  F:TextFile;
  s:string;
  queryword,parse,value,word,nick,desc,password:string;
  n:integer;
begin
  writeln('Content-type: text/html'#13#10);
  s := Replace(Trim(getenv('QUERY_STRING')),'%C3%BC','u');
  normalizeQueryString(s);
  queryword := '';
  for n:=1 to GetparseCount(s,'&') do begin
    parse := GetParse(s,'&',n);
    value := GetParse(parse,'=',2);
    parse := Getparse(parse,'=',1);
    if parse='word' then queryword := value;
    normalizeQueryString(value);
    if parse='word' then word := value
    else if parse='n' then nick := value
    else if parse='desc' then desc := value
    else if parse='pass' then password := value;
  end;
  normalizeword(word);
  if (desc='') or (nick='') or (password='') then begin
    writeln('404 Not Found');
  end else begin
    AssignFile(F,userFile);
    Append(F);
    writeln(F,'~'+nick);
    writeln(F,password);
    writeln(F,desc);
    writeln(F,DateToStr(Now));
    CloseFile(F);
    writeln('user: '+nick);
    writeln('pass: '+password);
    writeln('email: '+desc);
  end;
end.
