set(BackwardSrcDir ${CMAKE_SOURCE_DIR}/Dep/src/backward-cpp)
file(GLOB BackwardSrc ${BackwardSrcDir}/*.hpp ${BackwardSrcDir}/*.cpp)

add_library(Backward ${BackwardSrc})

target_include_directories(Backward PUBLIC ${BackwardSrcDir})
