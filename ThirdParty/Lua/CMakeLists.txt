set(SRC_CORE src/lapi.cpp src/lcode.cpp src/ldebug.cpp src/ldo.cpp src/ldump.cpp src/lfunc.cpp src/lgc.cpp src/llex.cpp
        src/lmem.cpp src/lobject.cpp src/lopcodes.cpp src/lparser.cpp src/lstate.cpp src/lstring.cpp src/ltable.cpp
        src/ltm.cpp src/lundump.cpp src/lvm.cpp src/lzio.cpp)
set(SRC_LIB src/lauxlib.cpp src/lbaselib.cpp src/ldblib.cpp src/liolib.cpp
        src/lmathlib.cpp src/loslib.cpp src/lstrlib.cpp src/ltablib.cpp src/loadlib.cpp src/linit.cpp)

include_directories(include)
add_library(Lua ${SRC_CORE} ${SRC_LIB})

if (BuildLuaInterpreter)
    set(SRC_LUA src/lua.cpp)
    add_executable(LuaInterpreter ${SRC_LUA})
    target_link_libraries(LuaInterpreter Lua)
endif ()
