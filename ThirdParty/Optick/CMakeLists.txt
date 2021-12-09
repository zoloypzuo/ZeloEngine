set(OptickSrcDir ${CMAKE_SOURCE_DIR}/Dep/src/optick/src)

add_library(Optick
        ${OptickSrcDir}/optick_capi.cpp
        ${OptickSrcDir}/optick_core.cpp
        ${OptickSrcDir}/optick_gpu.cpp
        ${OptickSrcDir}/optick_message.cpp
        ${OptickSrcDir}/optick_message.h
        ${OptickSrcDir}/optick_miniz.cpp
        ${OptickSrcDir}/optick_miniz.h
        ${OptickSrcDir}/optick_serialization.cpp
        ${OptickSrcDir}/optick_server.cpp
        )

target_include_directories(Optick PUBLIC ${OptickSrcDir})
