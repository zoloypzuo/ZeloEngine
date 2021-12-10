# created on 2021/7/26
# author @zoloypzuo
add_library(OS
        Time.cpp
        Input.cpp
        Window.cpp
        )

target_link_libraries(OS PUBLIC SDL)