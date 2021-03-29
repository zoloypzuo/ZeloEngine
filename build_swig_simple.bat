@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set Args=%*
cd /d %ScriptDir%

@echo on
swig -python -c++ -Wall -o Engine/zelo_wrapper.cxx -outdir ./build_swig Engine/zelo.i
swig -python -c++ -E Engine/zelo.i >build_swig/swig.log

cd %CurrentDir%
