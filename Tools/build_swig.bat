@rem build_swig.bat
@rem created on 2021/4/4
@rem author @zoloypzuo
@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..
set Args=%*

cd /d %EngineDir%
@echo on
mkdir build_swig
swig -python -c++ -Wall -o Engine/zelo_wrapper.cxx -outdir ./build_swig Engine/zelo.i
swig -python -c++ -E Engine/zelo.i >build_swig/swig.log

cd build_swig
cmake -DCMAKE_GENERATOR_PLATFORM=win32 -DBuildSwig=ON -G  "Visual Studio 15" ..
cmake --build . --config release --target zelo_py

cd %ScriptDir%

copy build_swig\zelo.py Script\scriptlibs\zelo.py
xcopy build_swig\Engine\Release\*.dll Script\scriptlibs\ /y
move Script\scriptlibs\zelo_py.dll Script\scriptlibs\_zelo.pyd

cd %CurrentDir%
pause