@rem %BuildDir%.bat
@rem created on 2021/4/4
@rem author @zoloypzuo
@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..
set Args=%*

cd /d %EngineDir%
@echo on
set BuildDir=build_swig_lua
set BuildType=RelWithDebInfo
set SwigScriptName=ZeloLua.i
set SwigWrapperName=ZeloWrapperLua.cxx
set ScriptDir=Script\Lua
set ScriptLibDir=Script\Lua\scriptlibs
set TargetName=ZeloWrapperLua
set InterpreterTargetName=LuaInterpreter

mkdir %BuildDir%

swig -lua -c++ -no-old-metatable-bindings -o Engine/%SwigWrapperName% -outdir ./%BuildDir%/Engine/%BuildType% Engine/%SwigScriptName%

cd %BuildDir%
cmake -DCMAKE_GENERATOR_PLATFORM=win32 -DBuildSwigLua=ON -G  "Visual Studio 16" ..
cmake --build . --config %BuildType% --target %TargetName%
cmake --build . --config %BuildType% --target %InterpreterTargetName%

cd /d %EngineDir%

xcopy %BuildDir%\Engine\%BuildType%\* %ScriptLibDir%\ /y
xcopy %BuildDir%\Engine\Lua\%BuildType%\* %ScriptLibDir%\ /y

cd %CurrentDir%
