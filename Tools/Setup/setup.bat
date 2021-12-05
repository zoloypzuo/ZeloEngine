@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on

cd ThirdParty

rem setup vcpkg

set VcpkgRoot=Vcpkg

if not exist %VcpkgRoot% git clone https://github.com.cnpmjs.org/Microsoft/vcpkg.git %VcpkgRoot%

if not exist %VcpkgRoot%\vcpkg.exe call %VcpkgRoot%\bootstrap-vcpkg.bat -disableMetrics

vcpkg\vcpkg.exe install --triplet x86-windows-static sdl2 glad assimp stb spdlog glm

rem imgui
cd /d %EngineDir%
@echo on
rd /s/q ThirdParty\TEMP
git clone https://gitee.com/zolozy/imgui.git --branch docking ThirdParty\TEMP\ImGui
xcopy /y/e ThirdParty\ImGui ThirdParty\TEMP\ImGui
xcopy /y/e ThirdParty\TEMP\ImGui ThirdParty\ImGui
rd /s/q ThirdParty\TEMP\ImGui\.git

rem optick
cd /d %EngineDir%
rd /s/q ThirdParty\TEMP
git clone https://gitee.com/zolozy/optick.git ThirdParty\TEMP\Optick
xcopy /y/e ThirdParty\Optick ThirdParty\TEMP\Optick
xcopy /y/e ThirdParty\TEMP\Optick ThirdParty\Optick
rd /s/q ThirdParty\TEMP\Optick\.git

cd %CurrentDir%
pause
