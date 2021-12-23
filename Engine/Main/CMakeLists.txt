add_executable(Hello Main.cpp)

target_link_libraries(Hello PRIVATE Engine)

if (DetectMemoryLeak)
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
