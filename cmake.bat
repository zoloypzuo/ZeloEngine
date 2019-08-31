@rem cmake.bat
@rem created on 2019/8/31
@rem author @zoloypzuo
@rem
@rem mkdir ../build and cmake build the project

@echo off

set SCRIPT_DIRECTORY=%~dp0
set CURRENT_DIRECTORY=%cd%
set ARGUMENTS=%*

@rem cd root dir
cd /d %SCRIPT_DIRECTORY%/..

@rem rm build and lib
rmdir /s/q build
rmdir /s/q lib

mkdir build
cd build

cmake -G "Visual Studio 15" ../ZeloEngine

cd /d %CURRENT_DIRECTORY%

pause