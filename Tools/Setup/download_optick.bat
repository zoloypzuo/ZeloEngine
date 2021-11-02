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
rd /s/q ThirdParty\TEMP
git clone https://gitee.com/zolozy/optick.git ThirdParty\TEMP\Optick
xcopy /y/e ThirdParty\TEMP\Optick ThirdParty\Optick
rd /s/q ThirdParty\TEMP\Optick\.git

cd %CurrentDir%
pause