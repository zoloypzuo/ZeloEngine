add_library(Foundation
        ZeloStringUtil.cpp
        ZeloIOStream.cpp
        ZeloProfiler.cpp
        ZeloStackTrace.cpp
        ZeloStb.cpp
        ZeloMemory.cpp
        )

option(USE_MIMALLOC "USE_MIMALLOC" ON)
if (USE_MIMALLOC)
    find_package(mimalloc CONFIG REQUIRED NO_SYSTEM_ENVIRONMENT_PATH)
    message(STATUS "mimalloc found. installed at: ${MIMALLOC_LIBRARY_DIR}")
    target_link_libraries(Foundation PRIVATE mimalloc mimalloc-static)

    target_compile_definitions(Foundation PRIVATE USE_MIMALLOC)
endif ()

target_link_libraries(Foundation PUBLIC Backward)
target_link_libraries(Foundation PUBLIC ABSL)

target_link_libraries(Foundation PRIVATE SDL)

find_package(Flatbuffers CONFIG REQUIRED)
target_link_libraries(Foundation PUBLIC flatbuffers::flatbuffers)
