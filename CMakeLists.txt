# created on 2019/9/23
# author @zoloypzuo
cmake_minimum_required(VERSION 3.18.4)

# C++ standard option
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# cmake option
set_property(GLOBAL PROPERTY USE_FOLDERS ON)  # Visual Studio will group targets into folders

option(BuildProfile "BuildProfile" OFF)
if (BuildProfile)
    set_property(GLOBAL PROPERTY RULE_LAUNCH_COMPILE "${CMAKE_COMMAND} -E time")
    # set_property(GLOBAL PROPERTY RULE_LAUNCH_LINK "${CMAKE_COMMAND} -E time") failed on windows
endif ()

project(ZeloEngine)

# detect platform
if (UNIX AND NOT APPLE)
    set(LINUX TRUE)
endif ()

# if(NOT LINUX) should work, too, if you need that
if (LINUX)
    message(STATUS "OS >>> Linux")
    # linux stuff here
elseif (WIN32)
    message(STATUS "OS >>> Windows")
    # stuff that should happen not on Linux
endif ()

if (CMAKE_SIZEOF_VOID_P EQUAL 8)  # 64 bits
    set(X64 TRUE)
elseif (CMAKE_SIZEOF_VOID_P EQUAL 4)  # 32 bits
    set(X32 TRUE)
endif ()

if (X64)
    message(STATUS "OS >>> X64")
else ()
    message(STATUS "OS >>> X32")
endif ()

message(STATUS "COMPILER >>> ${CMAKE_CXX_COMPILER_ID}")

message(STATUS "BUILD_SHARED_LIBS >>> ${BUILD_SHARED_LIBS}")

# cmake status
message(STATUS "PROJECT_BINARY_DIR >>> ${PROJECT_BINARY_DIR}")
message(STATUS "CMAKE_CXX_FLAGS >>> ${CMAKE_CXX_FLAGS}")
message(STATUS "CMAKE_CXX_FLAGS_DEBUG >>> ${CMAKE_CXX_FLAGS_DEBUG}")
message(STATUS "CMAKE_CXX_FLAGS_RELEASE >>> ${CMAKE_CXX_FLAGS_RELEASE}")

# set output path
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/bin)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_BINARY_DIR}/lib)

# vcpkg root and triplet
if (WIN32)
    if (X64)
        set(VCPKG_TARGET_TRIPLET x64-windows)
    else ()
        set(VCPKG_TARGET_TRIPLET x86-windows)
    endif ()
    set(VcpkgDir ${CMAKE_SOURCE_DIR}/ThirdParty/Vcpkg)
    include(${VcpkgDir}/scripts/buildsystems/vcpkg.cmake)
    message(STATUS vcpkg-toolchain-file=${VcpkgDir} \t triplet=${VCPKG_TARGET_TRIPLET})
else ()
    message(ERROR "platform not supported")
endif ()

# build third party from source
add_subdirectory(ThirdParty)

# find third party from vcpkg
find_package(glad CONFIG REQUIRED)
find_package(assimp CONFIG REQUIRED)
find_path(STB_INCLUDE_DIRS "stb.h")
find_package(unofficial-nativefiledialog CONFIG REQUIRED)

# absl
find_package(absl CONFIG REQUIRED)
add_library(ABSL INTERFACE)
target_link_libraries(ABSL INTERFACE absl::any absl::base absl::bits absl::city)

# sdl
find_package(SDL2 CONFIG REQUIRED)
add_library(SDL INTERFACE)
target_link_libraries(SDL INTERFACE SDL2::SDL2 SDL2::SDL2main)

# spdlog
find_package(spdlog CONFIG REQUIRED)
link_libraries(spdlog::spdlog spdlog::spdlog_header_only)

# glm
find_package(glm CONFIG REQUIRED)
link_libraries(glm::glm)
add_compile_definitions(GLM_FORCE_SWIZZLE)
add_compile_definitions(GLM_FORCE_RADIANS)

# C++ or platform options
if (MSVC)
    # ignore warning
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
    # avoid some bugs with Windows...
    add_compile_definitions(NOMINMAX)
    # We do this to speed up the build process,
    # it reduces the size of the Win32 header files by excluding some of the less used APIs.
    add_compile_definitions(WIN32_LEAN_AND_MEAN)

    set_property(GLOBAL PROPERTY
            MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif ()

# use unicode, wstring and etc
add_compile_definitions(UNICODE)

# engine option
add_compile_definitions(ZELO_DEBUG)

# build engine
add_subdirectory(Engine)

# build sandbox
add_subdirectory(Sandbox)

# build luabind
add_subdirectory(LuaBind)

# build tool
add_subdirectory(Tools)
