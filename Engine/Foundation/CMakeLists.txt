add_library(Foundation
        ZeloStringUtil.cpp
        ZeloIOStream.cpp
        ZeloProfiler.cpp
        )

target_link_libraries(Foundation PUBLIC Backward)
