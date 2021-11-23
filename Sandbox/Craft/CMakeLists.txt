
FILE(GLOB SOURCE_FILES *.cpp lib/*.cpp)
add_executable(craft ${SOURCE_FILES})

find_package(CURL CONFIG REQUIRED)
target_link_libraries(craft PRIVATE CURL::libcurl)

find_package(unofficial-sqlite3 CONFIG REQUIRED)
target_link_libraries(craft PRIVATE unofficial::sqlite3::sqlite3)

find_package(glfw3 CONFIG REQUIRED)
target_link_libraries(craft PRIVATE glfw)

find_package(GLEW REQUIRED)
target_link_libraries(craft PRIVATE GLEW::GLEW)
