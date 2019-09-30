@rem build.bat
@rem created on 2019/9/3
@rem author @zoloypzuo
@rem
@rem build the project

@rem uncomment this to log more and help debug
@echo off

set ScriptDir=%~dp0
set Args=%*

@rem cd root dir
cd /d %ScriptDir%

cd /d "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools"

call VsDevCmd.bat

cd /d %ScriptDir%

mkdir build
cd build

fxc /T vs_5_0 /Zi /Fo copy.vso ../copy.vs
fxc /T ps_5_0 /Zi /Fo copy.pso ../copy.ps

cl -I./DirectXMath/Inc -c -Z7 -o helloengine_d3d.obj ../helloengine_d3d.cpp
link -debug user32.lib d3d11.lib d3dcompiler.lib helloengine_d3d.obj

pause