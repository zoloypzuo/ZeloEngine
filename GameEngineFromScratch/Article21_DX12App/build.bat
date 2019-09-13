@rem build.bat
@rem created on 2019/9/13
@rem author @zoloypzuo

set CurrentDir=%cd%

set ScriptDir=%~dp0
cd /d %ScriptDir%

mkdir build
cd build
cmake -G "Visual Studio 15" ..
msbuild GameEngineFromScrath.sln

cd /d %CurrentDir%