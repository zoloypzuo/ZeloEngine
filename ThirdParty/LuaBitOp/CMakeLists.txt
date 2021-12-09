set(LuaBitOpSrcDir ${CMAKE_SOURCE_DIR}/Dep/src/LuaBitOp)
file(GLOB LuaBitOpSrc ${LuaBitOpSrcDir}/*.h ${LuaBitOpSrcDir}/*.c)

add_library(LuaBitOp ${LuaBitOpSrc})

target_link_libraries(LuaBitOp PUBLIC Lua)
target_include_directories(LuaBitOp PUBLIC ${LuaBitOpSrcDir})