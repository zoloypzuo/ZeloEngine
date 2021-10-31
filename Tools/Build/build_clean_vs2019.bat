@rem build_clean.bat
@rem created on 2021/4/4
@rem author @zoloypzuo
@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on
rd /s/q build_vs2019

cd %CurrentDir%
