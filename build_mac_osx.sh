#!/bin/bash

# copy lua header to include, fix sol compile error
# cp /home/zuoyiping01/ZeloEngine/Engine/Core/Lua/include/* /usr/local/include/

cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=/Users/zoloypzuo/Documents/vcpkg/scripts/buildsystems/vcpkg.cmake
cmake --build build
