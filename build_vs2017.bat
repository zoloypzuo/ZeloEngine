set CurrentDir=%cd%
set ScriptDir=%~dp0
set Args=%*
cd /d %ScriptDir%

mkdir build_vs2017
cd build_vs2017

cmake -DCMAKE_GENERATOR_PLATFORM=x64 -G  "Visual Studio 15" ..
cmake --build . --config release --target zelo

cd %CurrentDir%
pause
