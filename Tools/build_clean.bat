@rem build_clean.bat
@rem created on 2021/4/4
@rem author @zoloypzuo
@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..
set Args=%*

cd /d %EngineDir%
@echo on
rd /s/q build_swig
rd /s/q build_swig_lua
rd /s/q build_vs2017
rd /s/q build_vs2019
rd /s/q cmake-build-debug

cd %CurrentDir%
