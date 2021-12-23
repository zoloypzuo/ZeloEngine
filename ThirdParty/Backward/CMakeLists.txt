set(BackwardSrcDir ${CMAKE_SOURCE_DIR}/Dep/src/backward-cpp)
file(GLOB BackwardSrc ${BackwardSrcDir}/*.hpp)

add_library(Backward INTERFACE ${BackwardSrc})

target_include_directories(Backward INTERFACE ${BackwardSrcDir})
