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

@rem
@rem build lib here
@rem
call "lua-5.3.5/build.bat"

cd /d %CurrentDir%