@rem build_tools.bat
@rem created on 2021/11/28
@rem author @zoloypzuo
@rem visual studio 2019 x64 release
@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on
mkdir build_tools
cd build_tools
cmake .. -G "Visual Studio 16 2019" -A x64 -DZELO_GL_TRACER=OFF
cmake --build . --config release

cd %CurrentDir%
