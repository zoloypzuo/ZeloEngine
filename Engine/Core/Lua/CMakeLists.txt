set(SRC_CORE src/lapi.c src/lcode.c src/ldebug.c src/ldo.c src/ldump.c src/lfunc.c src/lgc.c src/llex.c
        src/lmem.c src/lobject.c src/lopcodes.c src/lparser.c src/lstate.c src/lstring.c src/ltable.c
        src/ltm.c src/lundump.c src/lvm.c src/lzio.c)
set(SRC_LIB src/lauxlib.c src/lbaselib.c src/ldblib.c src/liolib.c
        src/lmathlib.c src/loslib.c src/lstrlib.c src/ltablib.c src/loadlib.c src/linit.c)

include_directories(include)
add_library(Lua ${SRC_CORE} ${SRC_LIB})

set(SRC_LUA src/lua.c)
add_executable(LuaInterpreter ${SRC_LUA})
target_link_libraries(LuaInterpreter Lua)