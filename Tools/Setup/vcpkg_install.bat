@echo off
set CurrentDir=%cd%
set ScriptDir=%~dp0
set EngineDir=%ScriptDir%\..\..
set Args=%*

cd /d %EngineDir%
@echo on

cd %EngineDir%\ThirdParty
Vcpkg\vcpkg.exe install --triplet x86-windows abseil[cxx17] argparse assimp crossguid directx-headers directxmath flatbuffers glad glfw3 gli glm magic-enum meshoptimizer mimalloc nativefiledialog rapidjson refl-cpp sdl2 spdlog stb taskflow
Vcpkg\vcpkg.exe install --triplet x86-windows glad[extensions,gl-api-latest,gles1-api-latest,gles2-api-latest,glsc2-api-latest] --recurse
Vcpkg\vcpkg.exe install --triplet x64-windows abseil[cxx17] argparse assimp crossguid directx-headers directxmath flatbuffers glad glfw3 gli glm magic-enum meshoptimizer mimalloc nativefiledialog rapidjson refl-cpp sdl2 spdlog stb taskflow
Vcpkg\vcpkg.exe install --triplet x64-windows glad[extensions,gl-api-latest,gles1-api-latest,gles2-api-latest,glsc2-api-latest] --recurse
cd %CurrentDir%