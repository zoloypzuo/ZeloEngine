# created on 2019/8/27
# author @zoloypzuo

SET(SRC_LIST Demo1_Box.cpp Demo1_Box.h)

add_executable(Demo1_Box ${SRC_LIST})

# link lib
target_link_libraries(Demo1_Box Common)

set_target_properties(Demo1_Box PROPERTIES
        WIN32_EXECUTABLE YES  # use WinMain as entry point
        VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}  # set working directory as "./"
        )

# include "./", or IDE cannot generate definition for class
target_include_directories(Demo1_Box PRIVATE ../../Common)