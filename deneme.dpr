uses

  SysUtils;

var
  n:integer;
begin
  // QUERY_STRING  GetEnvironmentVariable
  writeln('Content-type: text/html'#13#10);
  writeln('<html>');
  writeln('<center>Merhaba</center>');
  writeln('<center>',ParamStr(1),'</center>');
  writeln('<form action="/cgi-bin/deneme.exe" method="GET"><input type="text" name="test"><input type=submit value="yolla"></form>');
  for n:=1 to 10 do begin
    writeln('<center>',IntToStr(n),'</center>');
  end;
  writeln('</html>');
end.