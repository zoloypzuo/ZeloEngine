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

Vcpkg\vcpkg.exe install --triplet x86-windows assimp curl glad glfw3 gli glm rapidjson^
    sdl2 spdlog sqlite3 taskflow
Vcpkg\vcpkg.exe install --triplet x86-windows glad[extensions,gl-api-latest,gles^
1-api-latest,gles2-api-latest,glsc2-api-latest] --recurse

cd %CurrentDir%
