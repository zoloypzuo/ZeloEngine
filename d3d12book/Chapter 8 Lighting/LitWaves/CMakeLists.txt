# created on 2019/9/12
# author @zoloypzuo

set(SRC_LIST
        FrameResource.h FrameResource.cpp
        LitWavesApp.cpp
        Waves.h Waves.cpp
        )

add_executable(LitWavesApp ${SRC_LIST})

set_target_properties(LitWavesApp PROPERTIES
        WIN32_EXECUTABLE YES  # use WinMain as entry point
        VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}  # set working directory as "./"
        )

target_link_libraries(LitWavesApp Common)