@rem build_ninja.bat
@rem created on 2021/4/4
@rem author @zoloypzuo
@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on
mkdir build_ninja
cd build_ninja
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\vsdevcmd.bat" -arch=x86 -host_arch=x64
cmake -DCMAKE_SYSTEM_VERSION="10.0.18362.0" -S .. -G Ninja
cmake --build . --config debug -j 18

cd %CurrentDir%
