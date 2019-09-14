@rem build.bat
@rem created on 2019/8/31
@rem author @zoloypzuo
@rem
@rem mkdir build and build the project

@rem uncomment this to log more and help debug
rem @echo off

set ScriptDir=%~dp0
set Args=%*
cd /d %ScriptDir%

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
call External/build.bat

@rem
@rem call submodule build here
@rem
rem call d3d12book/build.bat
rem call GameEngineFromScratch/Article21_DX12App/build.bat

pause