@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on

cd %EngineDir%\ThirdParty
Vcpkg\vcpkg.exe install --triplet x86-windows assimp curl glad glfw3 gli glm rapidjson sdl2 spdlog sqlite3 taskflow
Vcpkg\vcpkg.exe install --triplet x86-windows glad[extensions,gl-api-latest,gles1-api-latest,gles2-api-latest,glsc2-api-latest] --recurse
Vcpkg\vcpkg.exe install --triplet x64-windows assimp curl glad glfw3 gli glm rapidjson sdl2 spdlog sqlite3 taskflow
Vcpkg\vcpkg.exe install --triplet x64-windows glad[extensions,gl-api-latest,gles1-api-latest,gles2-api-latest,glsc2-api-latest] --recurse
cd %CurrentDir%