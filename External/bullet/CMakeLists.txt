cmake_minimum_required(VERSION 3.8)  # cmake 3.8 to use VS_DEBUGGER_WORKING_DIRECTORY
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)
project(bullet)
FILE(GLOB_RECURSE SRC_LIST bullet_linearmath/*.h bullet_linearmath/*.cpp)
ADD_LIBRARY(bullet_linearmath ${SRC_LIST})
target_include_directories(bullet_linearmath PRIVATE bullet_linearmath/include/ bullet_linearmath/include/LinearMath)
target_compile_definitions(bullet_linearmath PRIVATE WIN32 _CRT_SECURE_NO_WARNINGS)
