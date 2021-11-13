@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on
cd ThirdParty

rmdir /S /Q Vcpkg
mklink /D /J Vcpkg D:\ins\vcpkg

cd %CurrentDir%
pause
