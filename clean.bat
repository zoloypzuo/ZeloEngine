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

rd /s/q build_swig
rd /s/q build_vs2019

pause