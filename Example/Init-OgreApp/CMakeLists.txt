# created on 2019/10/9
# author @zoloypzuo

# add_executable(Init_OgreApp Init_OgreApp.h Init_OgreApp.cpp)

# set_target_properties(Init_OgreApp PROPERTIES
#         #        WIN32_EXECUTABLE YES  # use WinMain as entry point
#         VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}  # set working directory as "./"
#         )

# #target_link_libraries(Init_OgreApp
# #        ZeloMain
# #        SandboxFramework
# #        )

# # ogre

# # Note: 7 target(s) were omitted.
# target_link_libraries(Init_OgreApp PRIVATE

#         OgreHLMS OgreMain OgreBites OgrePaging)

# target_include_directories(Init_OgreApp PRIVATE
#         ${PROJECT_SOURCE_DIR}}/Src/SandboxFramework/Inc
#         ${PROJECT_SOURCE_DIR}}/Src/SandboxFramework/Inc/OGRE
#         ${PROJECT_SOURCE_DIR}}/Src/SandboxFramework/Inc/OGRE/Bites
#         )

cmake_minimum_required(VERSION 3.8)  # cmake 3.8 to use VS_DEBUGGER_WORKING_DIRECTORY
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

project(Init_OgreAppSln)

# set(OGRE_DIR D:\\ogre-1.12.1\\build\\cmake)
set(OGRE_DIR D:\\ogre-1.12.1\\build\\sdk\\CMake)

# specify which version and components you need
find_package(OGRE 1.11 REQUIRED COMPONENTS Bites RTShaderSystem)
# copy resource.cfg next to our binaries where OGRE looks for it
file(COPY ${OGRE_CONFIG_DIR}/resources.cfg DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
# add the source files as usual
add_executable(Init_OgreApp Init_OgreApp.cpp Init_OgreApp.h)
# this also sets the includes and pulls third party dependencies
target_link_libraries(Init_OgreApp OgreBites OgreRTShaderSystem)

