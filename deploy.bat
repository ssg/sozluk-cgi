@echo off
REM replace path variables with your web server's working directory
set "CGIBIN_DIR=C:\apache\cgi-bin\"
set "WWW_DIR=C:\apache\htdocs\"

echo Deploying cgi-bin executables...
copy *.exe "%CGIBIN_DIR%*.exe"
echo Deploying templates and user data...
copy *.txt "%CGIBIN_DIR%*.txt"
echo Deploying resources...
copy resources\*.* "%WWW_DIR%*.*"
echo All done
pause