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

Vcpkg\vcpkg.exe install --triplet x86-windows assimp curl glad glfw3 gli glm rapidjson^
    sdl2 spdlog sqlite3 taskflow
Vcpkg\vcpkg.exe install --triplet x86-windows glad[extensions,gl-api-latest,gles^
1-api-latest,gles2-api-latest,glsc2-api-latest] --recurse

cd %CurrentDir%
