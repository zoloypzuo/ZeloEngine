@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on
cd Playbox

rmdir /S /Q EtherealEngine
mklink /D /J EtherealEngine C:\Users\zoloypzuo\Documents\GitHub\EtherealEngine

cd %CurrentDir%
pause
