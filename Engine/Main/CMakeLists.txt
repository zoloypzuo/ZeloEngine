add_executable(Hello Main.cpp ProjectHub.cpp)

target_link_libraries(Hello PRIVATE Engine)
target_link_libraries(Hello PRIVATE Optick Whereami)  # ProjectHub

# vld
option(DETECT_MEMORY_LEAK "DetectMemoryLeak" OFF)
if (DETECT_MEMORY_LEAK)
    set(VldIncludeDir "C:/Program Files (x86)/Visual Leak Detector/include")
    if (X32)
        set(VldLibDir "C:/Program Files (x86)/Visual Leak Detector/lib/Win32")
    else ()
        set(VldLibDir "C:/Program Files (x86)/Visual Leak Detector/lib/Win64")
    endif ()
    add_library(Vld INTERFACE)
    target_include_directories(Vld INTERFACE ${VldIncludeDir})
    target_link_directories(Vld INTERFACE ${VldLibDir})
endif ()

if (DETECT_MEMORY_LEAK)
    add_compile_definitions(DETECT_MEMORY_LEAK)
    target_link_libraries(Hello PRIVATE Vld)
endif ()

# run build.py after C++ build
add_custom_command(TARGET Hello PRE_BUILD COMMAND
        python ${CMAKE_SOURCE_DIR}/Tools/Build/build.py
        ${CMAKE_SOURCE_DIR}
        $<TARGET_FILE_DIR:Hello>
        $<TARGET_FILE_DIR:Lua>/lua51.dll
        )

set_target_properties(Hello PROPERTIES FOLDER "Main")
