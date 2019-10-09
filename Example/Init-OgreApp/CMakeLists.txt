# created on 2019/10/9
# author @zoloypzuo

add_executable(Init_OgreApp Init_OgreApp.h Init_OgreApp.cpp)

set_target_properties(Init_OgreApp PROPERTIES
        #        WIN32_EXECUTABLE YES  # use WinMain as entry point
        VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}  # set working directory as "./"
        )

target_link_libraries(Init_OgreApp ZeloMain)