@rem build.bat
@rem created on 2019/9/14
@rem author @zoloypzuo

set CurrentDir=%cd%

set ScriptDir=%~dp0
cd /d %ScriptDir%

@rem
@rem build lib here
@rem
call "lua-5.3.5/build.bat"

cd /d %CurrentDir%