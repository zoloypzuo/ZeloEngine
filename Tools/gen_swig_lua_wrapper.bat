@rem %BuildDir%.bat
@rem created on 2021/4/4
@rem author @zoloypzuo
@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..
set Args=%*

cd /d %EngineDir%
set BuildDir=build_swig_lua
set BuildType=RelWithDebInfo
set SwigScriptName=ZeloLua.i
set SwigWrapperName=ZeloWrapperLua.cxx
set ScriptDir=Script\Lua
set ScriptLibDir=Script\Lua\scriptlibs
set TargetName=ZeloWrapperLua
set InterpreterTargetName=LuaInterpreter
@echo on

swig -lua -c++ -no-old-metatable-bindings -nomoduleglobal -o Engine/%SwigWrapperName% -outdir ./%BuildDir%/Engine/%BuildType% Engine/%SwigScriptName%

cd %CurrentDir%
