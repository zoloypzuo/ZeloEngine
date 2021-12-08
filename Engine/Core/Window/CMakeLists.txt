# created on 2021/7/26
# author @zoloypzuo
add_library(Window Window.cpp Input.cpp)

target_link_libraries(Window PUBLIC SDL2::SDL2 SDL2::SDL2main)