
FILE(GLOB SOURCE_FILES *.cpp lib/*.cpp)
add_library(Craft ${SOURCE_FILES} CraftPlugin.cpp CraftPlugin.h)

find_package(CURL CONFIG REQUIRED)
target_link_libraries(Craft PRIVATE CURL::libcurl)

find_package(unofficial-sqlite3 CONFIG REQUIRED)
target_link_libraries(Craft PRIVATE unofficial::sqlite3::sqlite3)

find_package(glfw3 CONFIG REQUIRED)
target_link_libraries(Craft PRIVATE glfw)

find_package(GLEW REQUIRED)
target_link_libraries(Craft PRIVATE GLEW::GLEW)
