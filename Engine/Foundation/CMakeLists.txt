add_library(Foundation
        ZeloStringUtil.cpp
        ZeloIOStream.cpp
        ZeloProfiler.cpp
        ZeloStackTrace.cpp
        )

target_link_libraries(Foundation PUBLIC Backward)
target_link_libraries(Foundation PRIVATE SDL)