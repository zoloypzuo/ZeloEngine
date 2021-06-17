#!/bin/bash

ScriptDir=.
EngineDir=..

cd $EngineDir
BuildDir=build_swig_lua
BuildType=RelWithDebInfo
SwigScriptName=ZeloLua.i
SwigWrapperName=ZeloWrapperLua.cxx
ScriptDir=Script/Lua
ScriptLibDir=Script/Lua/scriptlibs
TargetName=ZeloWrapperLua
InterpreterTargetName=LuaInterpreter

swig -lua -c++ -no-old-metatable-bindings -nomoduleglobal -o Engine/$SwigWrapperName -outdir ./$BuildDir/Engine/$BuildType Engine/$SwigScriptName
