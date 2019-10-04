set SCRIPT_DIRECTORY=%~dp0
set CURRENT_DIRECTORY=%cd%
set ARGUMENTS=%*

@rem cd root dir
cd /d %SCRIPT_DIRECTORY%


@rem copy Sandbox Resource config files to bin
xcopy config\ bin\ /s/e /y

echo on

tools\premake\premake5 --os=windows --file=premake/premake.lua vs2019 %ARGUMENTS%

cd /d %CURRENT_DIRECTORY%

pause