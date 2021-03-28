# created on 2021/3/28
# author @zoloypzuo
include_directories(include)
set(SRC
        src/zelo.cpp
        src/Engine.cpp
        src/Window.cpp
        )
add_library(zelo ${SRC})

option(BuildSwig "BuildSwig" OFF)
message(STATUS BuildSwig=${BuildSwig})

if (BuildSwig)  # build swig in win32 release
    add_library(zelo_py SHARED
            ${SRC}
            src/zelo_wrapper.cxx
            )

    target_include_directories(zelo_py PRIVATE $ENV{PYTHON_INCLUDE})
    target_link_libraries(zelo_py $ENV{PYTHON_LIB})
endif ()
