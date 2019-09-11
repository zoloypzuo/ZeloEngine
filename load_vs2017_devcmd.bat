@rem copy this to where you want to load vs2017 devcmd, and call it by git bash

set ScriptDir=%~dp0

cd /d "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools"

call VsDevCmd.bat

cd /d %ScriptDir%