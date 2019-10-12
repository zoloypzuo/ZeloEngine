@rem build.bat
@rem created on 2019/8/31
@rem author @zoloypzuo

set CurrentDir=%cd%
set ScriptDir=%~dp0
set Args=%*
cd /d %ScriptDir%

@rem
@rem lib build switch, uncomment this only when you want to rebuild lib
@rem
rem call External/build.bat

@rem
@rem call submodule build here
@rem
rem call d3d12book/build.bat
rem call GameEngineFromScratch/Article21_DX12App/build.bat

mkdir build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=C:/Users/zoloypzuo/Documents/vcpkg-master/scripts/buildsystems/vcpkg.cmake -G  "Visual Studio 16" ..
cmake --build . --config debug
cd %CurrentDir%

pause
