@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on

cd %EngineDir%\Tools\CodeGen
flatc.exe -c -o %EngineDir%\Engine --scoped-enums --no-warnings SceneData.fbs
flatc.exe -p -o %EngineDir%\Tools\Asset\SceneReader --scoped-enums --gen-object-api --no-warnings SceneData.fbs

cd %CurrentDir%
