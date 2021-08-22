@rem build_vs2019.bat
@rem created on 2021/4/4
@rem author @zoloypzuo
@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..
set Args=%*

cd /d %EngineDir%
@echo on
rd /s/q ThirdParty\TEMP
git clone https://gitee.com/zolozy/imgui.git --branch docking ThirdParty\TEMP\ImGui
move /Y ThirdParty\TEMP\ImGui ThirdParty\
rd /s/q ThirdParty\TEMP\ImGui\.git

cd %CurrentDir%
