uses

  SysUtils, Common;

procedure terminee;
begin
  writeln('<h1>404 Not Found</h1>');
  Flush(output);
  halt(1);
end;

procedure abort(s:string);
begin
  debug(s);
  Flush(output);
  halt(1);
end;

var
  I,O:TextFile;
  parse,value,word,s:string;
  deleted,ok,partial:boolean;
  index,count,n:integer;
begin
  s := QueryString;
  word := '';
  index := 6666;
  for n:=1 to GetParseCount(s,'&') do begin
    parse := GetParse(s,'&',n);
    value := Getparse(parse,'=',2);
    normalizeQueryString(value);
    parse := GetParse(parse,'=',1);
    if parse='word' then word := value else
      if parse='index' then index := StrToInt(value) else
      if parse = 'powerword' then begin
        word := value;
        index := 9999;
      end else terminee;
  end;
  if (word = '') or (index = 6666) then terminee;
  if word[1] = '*' then begin
    Delete(word,1,1);
    partial := true;
    debug('partially searching');
  end else partial := false;
  deleted := false;
  AssignFile(I,dictFile);
  AssignFile(O,tempFile);
  Reset(I);
  if IOResult <> 0 then abort('input open error - another user might be accessing the dictionary at the same time');
  ReWrite(O);
  if IOResult <> 0 then abort('output create error - two people might be using delete utility');
  count := 0;
  while not eof(I) do begin
    Readln(I,s);
    s := Trim(s);
    if s <> '' then if s[1] = '~' then begin
      if partial then ok := pos(word,s) > 0
                 else ok := s = '~'+word;
      if ok then begin
        debug('ok');
        inc(count);
        if count = index then begin
          deleted := true;
          repeat
            Readln(I,s);
            if s <> '' then if s[1]='~' then break;
          until Eof(I);
        end;
      end;
    end;
    Writeln(O,s);
  end;
  CloseFile(I);
  CloseFile(O);
  if deleted then begin
    DeleteFile(backupFile);
    RenameFile(dictFile,backupFile);
    RenameFile(tempFile,dictFile);
    debug('possible success :)');
  end else debug('no items found');
end.
