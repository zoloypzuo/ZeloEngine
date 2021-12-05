if (UNIX)  # fix std::filesystem link error
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    link_libraries(stdc++fs)
endif ()

option(DetectMemoryLeak     "DetectMemoryLeak"     OFF)  # 内存泄漏检测

# vld
if (DetectMemoryLeak)
    add_compile_definitions(DETECT_MEMORY_LEAK)
    set(VldIncludeDir "C:/Program Files (x86)/Visual Leak Detector/include")
    if (WIN32)
        set(VldLibDir "C:/Program Files (x86)/Visual Leak Detector/lib/Win32")
    else ()
        set(VldLibDir "C:/Program Files (x86)/Visual Leak Detector/lib/Win64")
    endif ()
    include_directories(${VldIncludeDir})
    link_directories(${VldLibDir})
endif ()

if (MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS=1)
    add_definitions(-D_SCL_SECURE_NO_WARNINGS=1)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP /bigobj /W3")
endif ()
if (MINGW)
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        add_definitions(-DDEBUG)
    endif ()
endif ()

function(target_add_ide_support target_name)
    if (NOT TARGET ${target_name})
        message(FATAL_ERROR "No target defined with name ${target_name}, cannot target_add_ide_support it.")
    endif()

    set (target_for_ide "${target_name}_ide")
    if (NOT TARGET ${target_for_ide})
        file(GLOB_RECURSE target_for_ide_srcs "*.h" "*.hpp" "*.hxx" "*.c" "*.cpp" "*.cxx" "*.cc")
        add_custom_target(${target_for_ide} SOURCES ${target_for_ide_srcs})
    endif()

endfunction(target_add_ide_support)