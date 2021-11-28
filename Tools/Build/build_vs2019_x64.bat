@rem build_vs2019_x64.bat
@rem created on 2021/11/28
@rem author @zoloypzuo
@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on
mkdir build_vs2019_x64
cd build_vs2019_x64
cmake .. -G "Visual Studio 16 2019" -A x64
cmake --build . --config debug

cd %CurrentDir%
