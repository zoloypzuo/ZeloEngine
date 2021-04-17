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

mkdir %BuildDir%

swig -lua -c++ -Wall -o Engine/%SwigWrapperName% -outdir ./%BuildDir%/Engine/%BuildType% Engine/%SwigScriptName%

cd %BuildDir%
cmake -DCMAKE_GENERATOR_PLATFORM=win32 -DBuildSwigLua=ON -G  "Visual Studio 16" ..
cmake --build . --config %BuildType% --target %TargetName%

cd /d %EngineDir%

xcopy %BuildDir%\Engine\%BuildType%\* %ScriptLibDir%\ /y

cd %CurrentDir%
