@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set Args=%*
cd /d %ScriptDir%

@echo on
call build_swig_simple.bat

mkdir build_swig
cd build_swig
cmake -G  "Visual Studio 15" ..
cmake --build . --config release --target zelo_py

cd %ScriptDir%

rem copy build_vs2019\src\Release\cyclone_py.dll ..\..\..\ZeloEngineScript\_cyclone.pyd
rem copy cyclone.py ..\..\..\ZeloEngineScript\cyclone.py

cd %CurrentDir%
pause
