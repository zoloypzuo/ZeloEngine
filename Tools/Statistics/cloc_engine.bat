@rem build_vs2019.bat
@rem created on 2021/4/4
@rem author @zoloypzuo
@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on

@echo off
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"

set "fullstamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"

echo %fullstamp% >> Tools\cloc_result.txt

cloc --exclude-dir=.git,.github,.idea,.vscode,build,build_vs2019,cmake-build-debug,Editor,ThirdParty,__Deprecated --exclude-ext=cxx . >> Tools\cloc_result.txt

echo %fullstamp%

cloc --exclude-dir=.git,.github,.idea,.vscode,build,build_vs2019,cmake-build-debug,Editor,ThirdParty,__Deprecated --exclude-ext=cxx .

cd %CurrentDir%
pause