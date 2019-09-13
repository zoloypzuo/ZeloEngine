@rem clean.bat
@rem created on 2019/9/2
@rem author @zoloypzuo
@rem
@rem copy this to where you want to rmdir build

@rem uncomment this to log more and help debug
rem @echo off

set ScriptDir=%~dp0
set Args=%*

@rem cd root dir
cd /d %ScriptDir%

@rem rmdir is not necessary unless you make some mistake in build directory
rmdir /s/q build

pause