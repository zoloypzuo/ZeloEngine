# created on 2019/9/12
# author @zoloypzuo

add_executable(Init_Direct3D InitDirect3DApp.cpp)

set_target_properties(Init_Direct3D PROPERTIES
        WIN32_EXECUTABLE YES  # use WinMain as entry point
        VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}  # set working directory as "./"
        )

target_link_libraries(Init_Direct3D Main)