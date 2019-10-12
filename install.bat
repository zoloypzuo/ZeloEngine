REM install.bat
REM created on 2019/10/12
REM author @zoloypzuo


REM vcpkg
REM ZeloEngine，这样windows全局可以使用lua脚本（包括引擎的bat-compiler）
setx PATH "%PATH%D:\vcpkg;D:\ZeloEngine;"

rem
rem Lua
rem

rem 初始化脚本
setx LUA_INIT_5_3 "@D:\ZeloEngine\Src\Script\global_init.lua"

rem require函数的搜索路径
rem 我们只额外添加D:\ZeloEngine\Src\Script\
rem 其他部分是由为zelo engine安装的luarocks生成的，附加了luarocks的路径
rem TODO 用户安装luarocks
setx LUA_PATH_5_3 ^
D:\ZeloEngine\Src\Script\?.lua;^
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
D:\LuaRocks\systree/share/lua/5.3/?/init.lua;

setx LUA_CPATH_5_3 ^
D:\ZeloEngine\?.dll;^
D:\ZeloEngine\..\lib\lua\5.3\?.dll;^
D:\ZeloEngine\loadall.dll;.\?.dll;^
D:\ZeloEngine\?53.dll;^
.\?53.dll;^
C:\Users\91018\AppData\Roaming/luarocks/lib/lua/5.3/?.dll;^
D:\LuaRocks\systree/lib/lua/5.3/?.dll

@rem TODO 用户安装powershell
powershell -executionpolicy remotesigned -File  Util/install/install_vcpkg.ps1
powershell -executionpolicy remotesigned -File  Util/install/install_vcpkg_packages.ps1
pause
