set CurrentDir=%cd%
set ScriptDir=%~dp0
set Args=%*
cd /d %ScriptDir%

mkdir build_vs2017
cd build_vs2017

rem TODO finish vs2017
rem cmake -DCMAKE_GENERATOR_PLATFORM=x64 -G  "Visual Studio 15" ..
cmake -G  "Visual Studio 15" ..
cmake --build . --config debug

cd %CurrentDir%
pause
