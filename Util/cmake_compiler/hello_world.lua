-- hello_world.lua
-- created on 2019/10/14
-- author @zoloypzuo

--[[
cmake_minimum_required(VERSION 2.8)

PROJECT (HELLO)

SET(SRC_LIST main.c)

MESSAGE(STATUS "This is BINARY dir " ${PROJECT_BINARY_DIR})
MESSAGE(STATUS "This is SOURCE dir " ${PROJECT_SOURCE_DIR})

ADD_EXECUTABLE(hello ${SRC_LIST})
]]

require "cmake_compiler.cmake"

hello_world = table.concat {
    cmake_header(),
    project "HELLO",
    set("SRC_LIST", "main.c"),
    log(cmake_string "This is BINARY dir ", "${PROJECT_BINARY_DIR}"),
    add_executable "hello"
}

print(hello_world)