SET(SRC_LIST Init_Direct3D.cpp Init_Direct3D.h)

# create Chapter4_Direct3D_Initialization exe target
add_executable(Chapter4_Direct3D_Initialization ${SRC_LIST})

# link lib
target_link_libraries(Chapter4_Direct3D_Initialization Common)

set_target_properties(Chapter4_Direct3D_Initialization PROPERTIES
        WIN32_EXECUTABLE YES  # use WinMain as entry point
        VS_DEBUGGER_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}  # set working directory as "./"
        )

# include "./", or IDE cannot generate definition for class
target_include_directories(Chapter4_Direct3D_Initialization PRIVATE ../Common)