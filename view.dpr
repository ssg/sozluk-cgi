uses

  Common, Classes, SysUtils, Windows;

const

  TemplateList : TStringList = NIL;

var
  s:string;
  templine:string;
  word,nick,date,desc:string;
  temp:string;
  I,O:TextFile;
  hastayimulan:string;
  n,p,p2,p3:integer;
  found:boolean;
begin
  word := queryString;
  AssignFile(I,showTemplateFile);
  Reset(I);
  repeat
    Readln(I,s);
    writeln(Replace(s,'%word',word));
  until s = '';
  TemplateList := TStringList.Create;
  repeat
    Readln(I,s);
    TemplateList.Add(s);
  until s = '';

  AssignFile(O,dictFile);  // 1-602-303 57 56
  Reset(O);
  found := false;
  s := '';
  while not Eof(O) do begin
    s := Translate(s,'ü','u');
    if s <> '' then if (s[1]='~') then if (copy(s,2,length(s))=word) then begin
      found := true;
      readln(O,nick);
      readln(O,date);
      date := GetParse(Trim(date),' ',1);
      desc := '';
      repeat
        readln(O,s);
        if s <> '' then begin
          if s[1] <> '~' then desc := desc + s + '<br>' else break;
        end;
      until Eof(O);
      hastayimulan := s;
      p := pos('(bkz',desc);
      while p > 0 do begin
        desc[p] := #$FF;
        temp := copy(desc,p,length(desc));
        p3 := pos(')',temp);
        p2 := 5;
        if p3 > p2 then begin
          s := Trim(copy(temp,p2,p3-p2));
          normalizeword(s);
          if s <> '' then begin
            Delete(desc,p2+p,(p3-p2)-1);
            s := ' <a href="/cgi-bin/view.exe?'+Translate(s,' ','+')+'">'+s+'</a>';
            Insert(s,desc,p2+p);
          end;
        end;
        p := pos('(bkz',desc);
      end;
      if getuserPass(nick) <> '' then nick := '<a href="/cgi-bin/view.exe?'+Translate(nick,' ','+')+'">'+nick+'</a>';
      desc := Translate(desc,#$FF,'(');
      for n:=0 to TemplateList.Count-1 do begin
        templine := Replace(TemplateList[n],'%nick',nick);
        templine := Replace(templine,'%date',date);
        templine := Replace(templine,'%desc',desc);
        writeln(templine);
      end;
      s := hastayimulan;
      if s <> '' then if (s[1]='~') then continue;
    end;
    Readln(O,s);
    s := Trim(s);
  end;
  CloseFile(O);
  if not found then writeln('Yok boyle bi$ii???');

  repeat
    Readln(I,s);
    writeln(Replace(s,'%word',word));
  until Eof(I);
  CloseFile(I);
end.
