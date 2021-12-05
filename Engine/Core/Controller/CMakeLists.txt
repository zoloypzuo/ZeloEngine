add_library(Controller CFreeLook.cpp CFreeMove.cpp)

target_link_libraries(Controller PUBLIC ECS)
target_link_libraries(Controller PRIVATE Input)
