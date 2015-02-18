uses

  Common, Classes, SysUtils, Windows;

type

  TWord = class(TObject)
    Count : longword;
    Date  : TDateTime;
    Word  : string;
  end; {case}

const

  hicolor = '#B00000';
  locolor = '#800000';
  WordList : TList = NIL;
  indexstr : string = '';
  totalentries : integer = 0;
  totalwords   : integer = 0;
  dayz         : integer = 0;

var

  noquery : boolean;
  hasdate : boolean;
  indexChar : string;

procedure buildindexstr;
var
  a:char;
  procedure addindex(showstr, querystr:string; hede:boolean);
  begin
    indexstr := indexstr + '<a href="/cgi-bin/index.exe'+querystr+'">';
    if hede then indexstr := indexstr + '<font color="'+hicolor+'"><b>'+showstr+'</b></font></a> '
            else indexstr := indexstr + showstr+'</a> ';
  end;
begin
  indexstr := '';
  addindex('0-9','?i=*',indexchar='*');
  for a := 'a' to 'z' do begin
    addindex(a,'?i='+a,indexchar=a);
  end;
  addindex('t&uuml;m&uuml;','?i=all',indexChar='all');
  addindex('taze','',queryString='');
end;

function FindWord(w:string):TWord;
var
  n:integer;
begin
  for n := 0 to WordList.Count-1 do begin
    Result := WordList[n];
    if Result.Word = w then exit;
  end;
  Result := NIL;
end;

function wordcompare(p1,p2:pointer):integer;
begin
  Result := CompareStr(TWord(p1).Word,TWord(p2).Word);
end;

var
  I:TextFile;
  authstr,numstr,desc,word,templine,searchstr,s:string;
  date,fd,td:TDateTime;
  T:TWord;
  n:integer;
  ok:boolean;
begin
  WordList := TList.Create;
  noquery := queryString='';
  buildindexstr;
  indexchar := getValue('i');
  searchstr := getValue('search');

  authstr := getValue('author');

  s := getValue('date');
  hasdate := s <> '';
  fd := 0;
  if hasdate then try
    fd := StrToDate(s);
  except
    hasdate := false;
  end;

  td := 0;
  s := getValue('todate');
  if s <> '' then try
    td := StrToDate(s);
  except
    td := Now;
  end;
  
  if FileExists(dictFile) then begin
    AssignFile(I,dictFile);
    Reset(I);
    s := '';
    while not Eof(I) do begin
      if s <> '' then if s[1]='~' then begin
        ok := true;
        templine := s;
        if indexChar='*' then ok := not (s[2] in ['a'..'z'])
          else if indexChar <> '' then if indexChar <> 'all' then ok := s[2] = indexChar[1];
        if ok then begin
          word := copy(s,2,length(s));
          Readln(I,s);
          if authstr <> '' then if pos(authstr,s) = 0 then continue;
          Readln(I,s);
          s := Getparse(Trim(s),' ',1);
          try
            date := StrToDate(s);
          except
            date := Trunc(Now);
          end;
          desc := '';
          while not Eof(I) do begin
            Readln(I,s);
            if s <> '' then
              if s[1] = '~' then break else desc := desc + Trim(s);
          end;

          if noquery then if date <> Trunc(Now) then continue else
            else if hasdate then if (date >= fd) and (date <= td) then continue;

          if searchstr <> '' then
            if pos(searchstr,desc) = 0 then
              if pos(searchstr,templine) = 0 then continue;

          T := FindWord(word);
          if T <> NIL then begin
            inc(T.Count);
            if date > T.Date then T.Date := date;
          end else begin
            T := TWord.Create;
            T.Word := word;
            T.Count := 1;
            T.Date := date;
            WordList.Add(T);
            inc(totalwords);
          end;
          inc(totalentries);
          continue;
        end;
      end; {if}
      Readln(I,s);
    end; {while}
    CloseFile(I);
  end else FileCreate(dictFile);
  WordList.Sort(wordcompare);
  AssignFile(I,indexTemplateFile);
  Reset(I);
  repeat
    Readln(I,s);
    s := Replace(s,'%totalwords',IntToStr(totalwords));
    s := Replace(s,'%totalentries',IntToStr(totalentries));
    writeln(Replace(s,'%index',indexstr));
  until s = '';
  Readln(I,templine);
  Flush(output);

  if WordList.Count = 0 then writeln('Hic kayIt yok') else for n:=0 to WordList.Count-1 do begin
    T := WordList[n];
    word := T.Word;
    if T.Count=1 then numstr := ''
                 else numstr := '('+IntToStr(T.Count)+')';
    if Trunc(T.Date) = Trunc(Now) then s := Replace(templine,'%linkcolor',hicolor)
                                  else s := Replace(templine,'%linkcolor',locolor);
    s := Replace(s,'%word',word);
    s := Replace(s,'%num',numstr);
    s := Replace(s,'%search',Translate(word,' ','+'));
    writeln(s);
  end;

  repeat
    Readln(I,s);
    writeln(s);
  until Eof(I);
  CloseFile(I);
end.
