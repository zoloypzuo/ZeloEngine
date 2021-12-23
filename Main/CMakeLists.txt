add_executable(Hello main.cpp)

target_link_libraries(Hello PRIVATE Engine StackTrace)

if (DetectMemoryLeak)
    add_compile_definitions(DETECT_MEMORY_LEAK)
    target_link_libraries(Hello PRIVATE Vld)
endif ()

# run build.py after C++ build
add_custom_command(TARGET Hello PRE_BUILD COMMAND
        py ${CMAKE_SOURCE_DIR}/build.py
        ${CMAKE_SOURCE_DIR}
        $<TARGET_FILE_DIR:Hello>
        $<TARGET_FILE_DIR:Lua>/lua51.dll
        )

set_target_properties(Hello PROPERTIES FOLDER "Main")
