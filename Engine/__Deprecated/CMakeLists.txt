# created on 2021/7/26
# author @zoloypzuo
# @formatter:off
option(UsePreCompiledHeader "UsePreCompiledHeader" OFF)  # 预编译头
option(BuildTest            "BuildTest"            OFF)  # 构建测试
# @formatter:on

# use precompiled header
if (UsePreCompiledHeader)
    set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMake")
    include(cotire)
endif ()

if (UsePreCompiledHeader)
    set_target_properties(Hello PROPERTIES COTIRE_CXX_PREFIX_HEADER_INIT "Engine/ZeloPreCompiledHeader.h")
    cotire(Hello)
endif ()

# build test
if (BuildTest)
    find_package(gtest CONFIG REQUIRED)

    include(CTest)
    enable_testing()
    add_subdirectory(Engine/Test)
endif ()
