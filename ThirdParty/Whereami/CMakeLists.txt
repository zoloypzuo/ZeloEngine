set(WhereamiSrcDir ${CMAKE_SOURCE_DIR}/Dep/src/whereami/src)
file(GLOB WhereamiSrc ${WhereamiSrcDir}/*.h ${WhereamiSrcDir}/*.c)

add_library(Whereami ${WhereamiSrc})

target_include_directories(Whereami PUBLIC ${WhereamiSrcDir})
