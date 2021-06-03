# created on 2021/3/28
# author @zoloypzuo

if (WIN32)
    # ignore warning
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
    # avoid some bugs with Windows...
    add_compile_definitions(NOMINMAX)
    # We do this to speed up the build process,
    # it reduces the size of the Win32 header files by excluding some of the less used APIs.
    add_compile_definitions(WIN32_LEAN_AND_MEAN)
endif ()

# first we compile lua from source
# lua <= sol <= engine object system
add_subdirectory(Core/Lua)
set(LUA_LIBRARIES Lua)
set(LUA_INCLUDE_DIR Core/Lua/include)
include_directories(${LUA_INCLUDE_DIR})
link_libraries(${LUA_LIBRARIES})

# vcpkg import sol
find_package(sol2 CONFIG REQUIRED)
link_libraries(sol2::sol2)
# sol enable safety check
add_compile_definitions(SOL_ALL_SAFETIES_ON)
# sol fix link error
add_compile_definitions(SOL_USING_CXX_LUA=0)

# use unicode, wstring and etc
add_compile_definitions(UNICODE)

# glm
add_compile_definitions(GLM_FORCE_SWIZZLE)
add_compile_definitions(GLM_FORCE_RADIANS)

# swig runtime debug log
if (0)  # too much log
    add_compile_definitions(SWIGRUNTIME_DEBUG)
endif ()

# build engine
include_directories(./)

add_compile_definitions(ZELO_DEBUG)
add_compile_definitions(DEBUG_SHADOWMAP)

add_subdirectory(Core)
link_libraries(Core)

add_subdirectory(Core/ImGui) # use my own ImGui implementation
link_libraries(ImGui)

add_subdirectory(Renderer/OpenGL)
link_libraries(OpenGLRenderer)

file(GLOB CommonSrc *.cpp *.cxx Component/*.cpp Util/*.c Util/*.cpp)
add_library(Common ${CommonSrc})


if (0)  # not used for now
    add_subdirectory(Core/Physics)
endif ()
