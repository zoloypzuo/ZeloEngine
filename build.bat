@rem build.bat
@rem created on 2019/8/31
@rem author @zoloypzuo
@rem
@rem mkdir build and build the project

@rem comment this to log more and help debug
@echo off

set CurrentDir=%cd%
set ScriptDir=%~dp0
set Args=%*
cd /d %ScriptDir%

@rem
@rem set environment variable
@rem
setx LUA_INIT_5_3 "@D:\ZeloEngine\Src\Script\global.lua"
setx LUA_PATH_5_3 ^
D:\LuaRocks\lua\?.lua;^
D:\LuaRocks\lua\?\init.lua;^
D:\ZeloEngine\lua\?.lua;^
D:\ZeloEngine\lua\?\init.lua;^
D:\ZeloEngine\?.lua;^
D:\ZeloEngine\?\init.lua;^
D:\ZeloEngine\..\share\lua\5.3\?.lua;^
D:\ZeloEngine\..\share\lua\5.3\?\init.lua;^
.\?.lua;^
.\?\init.lua;^
C:\Users\91018\AppData\Roaming/luarocks/share/lua/5.3/?.lua;^
C:\Users\91018\AppData\Roaming/luarocks/share/lua/5.3/?/init.lua;^
D:\LuaRocks\systree/share/lua/5.3/?.lua;^
D:\LuaRocks\systree/share/lua/5.3/?/init.lua;^
D:\ZeloEngine\Src\Script\?.lua

setx LUA_CPATH_5_3 ^
D:\ZeloEngine\?.dll;^
D:\ZeloEngine\..\lib\lua\5.3\?.dll;^
D:\ZeloEngine\loadall.dll;.\?.dll;^
D:\ZeloEngine\?53.dll;^
.\?53.dll;^
C:\Users\91018\AppData\Roaming/luarocks/lib/lua/5.3/?.dll;^
D:\LuaRocks\systree/lib/lua/5.3/?.dll


@rem
@rem load vs2017 devcmd.bat
@rem
if not defined IsVsDevCmdLoaded (
  set IsVsDevCmdLoaded="True"
  call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"
)

@rem
@rem lib build switch, uncomment this only when you want to rebuild lib
@rem
rem call External/build.bat

@rem
@rem call submodule build here
@rem
rem call d3d12book/build.bat
rem call GameEngineFromScratch/Article21_DX12App/build.bat

@rem build zelo
mkdir build
cd build
cmake -G "Visual Studio 15" ..
msbuild ZeloEngine.sln
cd %CurrentDir%

pause