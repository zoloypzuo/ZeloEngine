set(SRC_CORE src/lapi.cpp src/lcode.cpp src/ldebug.cpp src/ldo.cpp src/ldump.cpp src/lfunc.cpp src/lgc.cpp src/llex.cpp
        src/lmem.cpp src/lobject.cpp src/lopcodes.cpp src/lparser.cpp src/lstate.cpp src/lstring.cpp src/ltable.cpp
        src/ltm.cpp src/lundump.cpp src/lvm.cpp src/lzio.cpp)
set(SRC_LIB src/lauxlib.cpp src/lbaselib.cpp src/ldblib.cpp src/liolib.cpp
        src/lmathlib.cpp src/loslib.cpp src/lstrlib.cpp src/ltablib.cpp src/loadlib.cpp src/linit.cpp)

add_library(Lua SHARED ${SRC_CORE} ${SRC_LIB})

target_include_directories(Lua PRIVATE include)
target_compile_definitions(Lua PRIVATE LUA_BUILD_AS_DLL)
set_target_properties(Lua PROPERTIES OUTPUT_NAME "lua51")

if (BuildLuaInterpreter)
    set(SRC_LUA src/lua.cpp)
    add_executable(LuaInterpreter ${SRC_LUA})
    target_link_libraries(LuaInterpreter Lua)
endif ()
