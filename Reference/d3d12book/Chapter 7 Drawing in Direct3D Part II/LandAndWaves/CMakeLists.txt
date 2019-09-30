# created on 2019/9/12
# author @zoloypzuo

set(SRC_LIST
        FrameResource.cpp FrameResource.h
        LandAndWavesApp.cpp
        Waves.cpp Waves.h
        )

add_executable(LandAndWavesApp ${SRC_LIST})

set_target_properties(LandAndWavesApp PROPERTIES
        WIN32_EXECUTABLE YES  # use WinMain as entry point
        VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}  # set working directory as "./"
        )

target_link_libraries(LandAndWavesApp Common)