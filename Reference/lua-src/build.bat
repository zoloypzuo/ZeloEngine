@rem build.bat
@rem created on 2019/9/14
@rem author @zoloypzuo

set CurrentDir=%cd%

set ScriptDir=%~dp0
cd /d %ScriptDir%

if not defined IsVsDevCmdLoaded (
    set IsVsDevCmdLoaded="True"
    call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"
)

mkdir build
cd build
cmake -G "Visual Studio 15" ..
msbuild lua.sln -property:Configuration=Debug

cd ..
copy build\Debug\lua.lib ..\..\Lib\Win32Debug\lua.lib
copy build\Debug\lua.pdb ..\..\Lib\Win32Debug\lua.pdb

cd /d %CurrentDir%