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
set BuildType=RelWithDebInfo

swig -python -c++ -Wall -o Engine/zelo_wrapper.cxx -outdir ./build_swig/Engine/%BuildType% Engine/zelo.i
swig -python -c++ -E Engine/zelo.i >build_swig/swig.log

cd build_swig
cmake -DCMAKE_GENERATOR_PLATFORM=win32 -DBuildSwig=ON -G  "Visual Studio 16" ..
cmake --build . --config %BuildType% --target zelo_py

cd /d %EngineDir%

xcopy build_swig\Engine\RelWithDebInfo\* Script\scriptlibs\ /y

cd %CurrentDir%
pause