uses

  Classes, Common, SysUtils, Windows;

var
  T:TFileStream;
  F:TextFile;
  queryword,word,nick,desc,password,realpass:string;
  n:integer;
  msg:string;
  s:string;
begin
  queryword := '';
  word := getValue('word');
  nick := getValue('nick');
  desc := getValue('desc');
  password := getvalue('password');
  normalizeword(word);
  realpass := GetUserPass(nick);
  if (desc='') or (nick='') or (word='') or (realpass='') or (realpass <> password) then begin
    msg := 'OLMAZ SENiN i$iN!'
  end else begin
    T := TFileStream.Create(dictFile,fmOpenWrite);
    T.Position := T.Size;
    msg := '~'+word + #13#10 + nick + #13#10 + DateToStr(Now)+' '+getenv('REMOTE_ADDR') + #13#10 +
           desc + #13#10;
    T.Write(msg[1],System.length(msg));
    T.Free;
    msg := 'EKLEDiM!';
    CloseFile(F);
  end;
  AssignFile(F,addTemplateFile);
  Reset(F);
  while not Eof(F) do begin
    readln(F,s);
    s := Replace(s,'%msg',msg);
    s := Replace(s,'%queryword',Translate(word,' ','+'));
    writeln(s);
  end;
  CloseFile(F);
end.
