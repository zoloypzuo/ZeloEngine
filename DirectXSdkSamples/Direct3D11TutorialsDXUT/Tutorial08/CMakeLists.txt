cmake_minimum_required(VERSION 3.1)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)
project(Tutorial08)

# include dxut
include_directories("${PROJECT_SOURCE_DIR}/../../../3rdParty/DXUT-apr2019/Core")
include_directories("${PROJECT_SOURCE_DIR}/../../../3rdParty/DXUT-apr2019/Optional")

# link lib dir
link_directories("${PROJECT_SOURCE_DIR}/../../../Lib/Win32Debug")

# add_subdirectory()

# create an exe target
add_executable(Tutorial08 Tutorial08.cpp)

# link lib
target_link_libraries(Tutorial08 user32.lib)

# generate proper GUI program on specified platform
if(WIN32) # Check if we are on Windows
	if(MSVC) # Check if we are using the Visual Studio compiler
		set_target_properties(Tutorial08 PROPERTIES
			WIN32_EXECUTABLE YES  # use WinMain as entry point
			# LINK_FLAGS "/ENTRY:mainCRTStartup"
		)
	else()
		message(SEND_ERROR "You are using an unsupported Windows compiler! (Not MSVC or GCC)")
	endif(MSVC)
else()
	message(SEND_ERROR "You are on an unsupported platform! (Not Win32, Mac OS X or Unix)")
endif(WIN32)