@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on

cd %EngineDir%\Tools\Setup
python bootstrap.py -b %EngineDir%\Dep --bootstrap-file bootstrap.json

cd %EngineDir%\ThirdParty

rmdir /S /Q Vcpkg
mklink /D /J Vcpkg C:\_Root\Portable\vcpkg
rmdir /S /Q Resource
mklink /D /J Resource C:\_Root\Svn\ZeloEngineResource

if not exist Vcpkg\vcpkg.exe (
    setx X_VCPKG_ASSET_SOURCES "x-azurl,http://106.15.181.5/"
    call Vcpkg\bootstrap-vcpkg.bat -disableMetrics
)

cd %EngineDir%\Tools\Setup
call vcpkg_install.bat

cd %CurrentDir%
