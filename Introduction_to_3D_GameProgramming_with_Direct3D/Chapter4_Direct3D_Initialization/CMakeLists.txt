SET(SRC_LIST D3DApp.cpp Init_Direct3D.cpp)

# create Chapter4_Direct3D_Initialization exe target
add_executable(Chapter4_Direct3D_Initialization ${SRC_LIST})

# link lib
# target_link_libraries(Tutorial08 user32.lib)

set_target_properties(Chapter4_Direct3D_Initialization PROPERTIES
	WIN32_EXECUTABLE YES  # use WinMain as entry point
	VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}  # set working directory as "./"
)