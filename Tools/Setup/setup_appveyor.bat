@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on

git submodule update

if not exist Dep (
    md Dep
)

cd %EngineDir%\Tools\Setup
python check_prerequisite.py
python bootstrap.py -b %EngineDir%\Dep --bootstrap-file bootstrap.json --skip vcpkg

cd %EngineDir%\ThirdParty

if not exist Vcpkg (
    mklink /D /J Vcpkg c:\tools\vcpkg
    pushd Vcpkg
    git pull -q
    popd
)

if not exist Vcpkg\vcpkg.exe (
    call Vcpkg\bootstrap-vcpkg.bat -disableMetrics
)

cd %EngineDir%\Tools\Setup
call vcpkg_install.bat

cd %CurrentDir%
