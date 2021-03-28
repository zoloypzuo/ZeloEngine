@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set Args=%*
cd /d %ScriptDir%

@echo on
swig -python -c++ -Wall -o Engine/src/zelo_wrapper.cxx -outdir ./build_swig Engine/include/zelo.i
swig -python -c++ -E Engine/include/zelo.i >build_swig/swig.log

cd %CurrentDir%
