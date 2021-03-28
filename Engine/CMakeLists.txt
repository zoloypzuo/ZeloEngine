# created on 2021/3/28
# author @zoloypzuo
include_directories(include)
add_library(zelo src/zelo.cpp)
add_library(zelo_py SHARED
        src/zelo.cpp
        src/zelo_wrapper.cxx
        )

target_include_directories(zelo_py PRIVATE $ENV{PYTHON_INCLUDE})
target_link_libraries(zelo_py $ENV{PYTHON_LIB})
