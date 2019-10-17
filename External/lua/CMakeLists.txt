cmake_minimum_required(VERSION 3.8)  # cmake 3.8 to use VS_DEBUGGER_WORKING_DIRECTORY
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)
project(lua)
file(GLOB_RECURSE SRC_LIST include/*.h src/*.c)
MESSAGE(STATUS ${SRC_LIST})
ADD_LIBRARY(lua ${SRC_LIST})
target_include_directories(lua PRIVATE include)
target_compile_definitions(lua PRIVATE WIN32 _CRT_SECURE_NO_WARNINGS)
