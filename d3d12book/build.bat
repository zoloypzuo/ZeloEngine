@rem build.bat
@rem created on 2019/9/13
@rem author @zoloypzuo
@rem
@rem build dxd12book

set CurrentDir=%cd%

set ScriptDir=%~dp0
cd /d %ScriptDir%

mkdir build
cd build
cmake -G "Visual Studio 15" ..
msbuild dxd12book.sln

cd /d %CurrentDir%