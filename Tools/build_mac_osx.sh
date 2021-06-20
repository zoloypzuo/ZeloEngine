#!/bin/bash

# copy lua header to include, fix sol compile error
cp /Users/zoloypzuo/Documents/ZeloEngine/Engine/Core/Lua/include/* /usr/local/include/

cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=/Users/zoloypzuo/Documents/vcpkg/scripts/buildsystems/vcpkg.cmake
cmake --build build
