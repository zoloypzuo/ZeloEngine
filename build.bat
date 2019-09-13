@rem build.bat
@rem created on 2019/8/31
@rem author @zoloypzuo
@rem
@rem mkdir build and build the project

@rem uncomment this to log more and help debug
@echo off

set ScriptDir=%~dp0
set Args=%*

@rem cd root dir
cd /d %ScriptDir%

@rem rmdir is not necessary unless you make some mistake in build directory
rem rmdir /s/q build

mkdir build
cd build

cmake -G "Visual Studio 15" ..

cd /d "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools"

call VsDevCmd.bat

cd /d %ScriptDir%

msbuild build/ZeloEngine.sln

@rem
@rem build dxd12book
@rem
cd d3d12book
mkdir build
cd build
cmake -G "Visual Studio 15" ..
msbuild dxd12book.sln

pause