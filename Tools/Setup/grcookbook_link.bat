@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on
cd Sandbox\GRCookbook

rmdir /S /Q data
rmdir /S /Q deps
rmdir /S /Q shared
mklink /D /J data C:\Users\zoloypzuo\Documents\GitHub\3D-Graphics-Rendering-Cookbook\data
mklink /D /J deps C:\Users\zoloypzuo\Documents\GitHub\3D-Graphics-Rendering-Cookbook\deps
mklink /D /J shared C:\Users\zoloypzuo\Documents\GitHub\3D-Graphics-Rendering-Cookbook\shared

cd %CurrentDir%
pause
