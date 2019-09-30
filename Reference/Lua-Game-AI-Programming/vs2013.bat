@echo off

set SCRIPT_DIRECTORY=%~dp0
set CURRENT_DIRECTORY=%cd%
set ARGUMENTS=%*

@rem cd root dir
cd /d %SCRIPT_DIRECTORY%

@rem rm build and lib
rmdir /s/q build
rmdir /s/q lib

@rem clear bin
rmdir /s/q bin
mkdir bin

@rem copy Sandbox Resource config files to bin
xcopy config\SandboxResource_cfg bin /s/e /y

echo on

tools\premake\premake5 --os=windows --file=premake/premake.lua vs2013 %ARGUMENTS%

cd /d %CURRENT_DIRECTORY%