add_library(Foundation
        ZeloStringUtil.cpp
        ZeloIOStream.cpp
        ZeloProfiler.cpp
        ZeloStackTrace.cpp
        ZeloStb.cpp
        )

target_link_libraries(Foundation PUBLIC Backward)
target_link_libraries(Foundation PRIVATE SDL)

find_package(Flatbuffers CONFIG REQUIRED)
target_link_libraries(Foundation PUBLIC flatbuffers::flatbuffers)