# created on 2019/9/23
# author @zoloypzuo

#
# cotire (https://github.com/sakra/cotire)
#
set (CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMake")
include(cotire)
#
# 想要用cotire预编译加速一个target，cotire下即可，如：
#
#​add_executable(MyExecutable ${MyExecutableSources})
#​target_link_libraries(MyExecutable ${MyExecutableLibraries})
#​cotire(MyExecutable)