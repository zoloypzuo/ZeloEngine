FILE(GLOB SOURCE_FILES *.cpp thirdparty/*.cpp)
add_library(Craft ${SOURCE_FILES} CraftPlugin.cpp CraftPlugin.h)

target_link_libraries(Craft PUBLIC Engine)

find_package(CURL CONFIG REQUIRED)
target_link_libraries(Craft PRIVATE CURL::libcurl)

find_package(unofficial-sqlite3 CONFIG REQUIRED)
target_link_libraries(Craft PRIVATE unofficial::sqlite3::sqlite3)

find_package(glad CONFIG REQUIRED)
target_link_libraries(Craft PRIVATE glad::glad)