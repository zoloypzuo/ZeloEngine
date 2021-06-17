#!/bin/bash

# copy lua header to include, fix sol compile error
cp /home/zuoyiping01/ZeloEngine/Engine/Core/Lua/include/* /usr/local/include/

md build
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=/home/zuoyiping01/vcpkg/scripts/buildsystems/vcpkg.cmake
cmake --build build
