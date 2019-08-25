# template header declaration
cmake_minimum_required(VERSION 3.8)  # cmake 3.8 to use VS_DEBUGGER_WORKING_DIRECTORY
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)
project(ZeloEngine)

# include dxut
include_directories("${PROJECT_SOURCE_DIR}/3rdParty/DXUT-apr2019/Core")
include_directories("${PROJECT_SOURCE_DIR}/3rdParty/DXUT-apr2019/Optional")

# link lib dir
link_directories("${PROJECT_SOURCE_DIR}/Lib/Win32Debug")

# # create Tutorial08 exe target
# add_executable(Tutorial08 DirectXSdkSamples/Tutorial08/Tutorial08.cpp)  # create an exe target

# # create Lesson1_Create_a_Window exe target
# add_executable(Lesson1_Create_a_Window "${PROJECT_SOURCE_DIR}/DirectX11Basic/Lesson1_Create_a_Window/Lesson1_Create_a_Window.cpp")

# # create Lesson2_DirectX_Init exe target
# add_executable(Lesson2_DirectX_Init "${PROJECT_SOURCE_DIR}/DirectX11Basic/Lesson2_DirectX_Init/Lesson2_DirectX_Init.cpp")

# link lib
# target_link_libraries(Tutorial08 user32.lib)

# set_target_properties(Tutorial08 PROPERTIES
# 	WIN32_EXECUTABLE YES  # use WinMain as entry point
# 	VS_DEBUGGER_WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}/DirectXSdkSamples/Tutorial08/"
# )
# set_target_properties(Lesson1_Create_a_Window PROPERTIES
# 	WIN32_EXECUTABLE YES  # use WinMain as entry point
# )
# set_target_properties(Lesson2_DirectX_Init PROPERTIES
# 	WIN32_EXECUTABLE YES  # use WinMain as entry point
# )
# set_target_properties(Lesson2_DirectX_Init PROPERTIES
# 	WIN32_EXECUTABLE YES  # use WinMain as entry point
# )


add_subdirectory(Introduction_to_3D_GameProgramming_with_Direct3D)