set(TupleUtilsSrcDir ${CMAKE_SOURCE_DIR}/Dep/src/tuple-utils/tuple-utils)

add_library(TupleUtils INTERFACE)

target_include_directories(TupleUtils INTERFACE ${TupleUtilsSrcDir})
