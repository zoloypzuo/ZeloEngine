@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on

if not exist Dep (
    md Dep
)

cd %EngineDir%\Tools\Setup
python check_prerequisite.py
python bootstrap.py -b %EngineDir%\Dep --bootstrap-file bootstrap.json

cd %EngineDir%\ThirdParty

if not exist Vcpkg (
    mklink /D /J Vcpkg %EngineDir%\Dep\src\vcpkg
)

if not exist Vcpkg\vcpkg.exe (
    setx X_VCPKG_ASSET_SOURCES "x-azurl,http://106.15.181.5/"
    call Vcpkg\bootstrap-vcpkg.bat -disableMetrics
)

cd %CurrentDir%
call vcpkg_install.bat

cd %CurrentDir%
