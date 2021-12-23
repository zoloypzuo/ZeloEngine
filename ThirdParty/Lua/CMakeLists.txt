set(LuaSrcDir ${CMAKE_SOURCE_DIR}/Dep/src/lua/src)
set(LuaHppDir ${CMAKE_SOURCE_DIR}/Dep/src/lua/etc)

set(SRC_CORE
        ${LuaSrcDir}/lapi.c
        ${LuaSrcDir}/lcode.c
        ${LuaSrcDir}/ldebug.c
        ${LuaSrcDir}/ldo.c
        ${LuaSrcDir}/ldump.c
        ${LuaSrcDir}/lfunc.c
        ${LuaSrcDir}/lgc.c
        ${LuaSrcDir}/llex.c
        ${LuaSrcDir}/lmem.c
        ${LuaSrcDir}/lobject.c
        ${LuaSrcDir}/lopcodes.c
        ${LuaSrcDir}/lparser.c
        ${LuaSrcDir}/lstate.c
        ${LuaSrcDir}/lstring.c
        ${LuaSrcDir}/ltable.c
        ${LuaSrcDir}/ltm.c
        ${LuaSrcDir}/lundump.c
        ${LuaSrcDir}/lvm.c
        ${LuaSrcDir}/lzio.c
        )
set(SRC_LIB
        ${LuaSrcDir}/lauxlib.c
        ${LuaSrcDir}/lbaselib.c
        ${LuaSrcDir}/ldblib.c
        ${LuaSrcDir}/liolib.c
        ${LuaSrcDir}/lmathlib.c
        ${LuaSrcDir}/loslib.c
        ${LuaSrcDir}/lstrlib.c
        ${LuaSrcDir}/ltablib.c
        ${LuaSrcDir}/loadlib.c
        ${LuaSrcDir}/linit.c
        )

add_library(Lua SHARED ${SRC_CORE} ${SRC_LIB})

target_include_directories(Lua PUBLIC ${LuaSrcDir})
target_compile_definitions(Lua PRIVATE LUA_BUILD_AS_DLL LUA_USE_APICHECK)
set_target_properties(Lua PROPERTIES OUTPUT_NAME "lua51")

target_include_directories(Lua INTERFACE ${LuaHppDir})
