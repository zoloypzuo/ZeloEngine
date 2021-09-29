@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..
set Args=%*

cd /d %EngineDir%
@echo on
cd cmake-build-debug

Hello.exe
cd %CurrentDir%