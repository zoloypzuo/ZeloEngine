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
mkdir build_vs2019
cd build_vs2019
cmake -DCMAKE_GENERATOR_PLATFORM=win32 -G  "Visual Studio 16" ..
cmake --build . --config debug

cd %CurrentDir%
