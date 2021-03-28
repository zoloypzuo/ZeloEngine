@echo off
@rem build.bat
@rem created on 2019/8/31
@rem author @zoloypzuo

set CurrentDir=%cd%
set ScriptDir=%~dp0
set Args=%*
cd /d %ScriptDir%

@echo on
mkdir build_vs2019
cd build_vs2019
rem cmake -DCMAKE_TOOLCHAIN_FILE=CMake/vcpkg.cmake -G  "Visual Studio 16" ..
cmake -G  "Visual Studio 16" ..
cmake --build . --config release
cd %CurrentDir%
