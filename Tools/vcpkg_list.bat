@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..
set Args=%*

cd /d %EngineDir%
@echo on
cd ThirdParty

Vcpkg\vcpkg.exe list
Vcpkg\vcpkg.exe list > vcpkg_list.txt

cd %CurrentDir%
pause
