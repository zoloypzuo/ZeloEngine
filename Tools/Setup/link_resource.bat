@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on

rmdir /S /Q Resource
mklink /D /J Resource C:\_Root\Svn\ZeloEngineResource

cd %CurrentDir%
pause
