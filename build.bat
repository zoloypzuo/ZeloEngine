@rem build.bat
@rem created on 2019/8/31
@rem author @zoloypzuo
@rem
@rem mkdir build and build the project

@rem uncomment this to log more and help debug
@echo off

set ScriptDir=%~dp0
set Args=%*
cd /d %ScriptDir%

@rem
@rem load vs2017 devcmd.bat
@rem
cd /d "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools"
call VsDevCmd.bat
cd /d %ScriptDir%

@rem
@rem call submodule build here
@rem
call d3d12book/build.bat

pause