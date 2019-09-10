# created on 2019/9/10
# author @zoloypzuo

add_executable(Box BoxApp.cpp)

set_target_properties(Box PROPERTIES
        WIN32_EXECUTABLE YES  # use WinMain as entry point
        VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}  # set working directory as "./"
        )

target_link_libraries(Box Common)