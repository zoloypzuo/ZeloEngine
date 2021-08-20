# created on 2021/8/16
# author @zoloypzuo
add_subdirectory(ImGuiBackend)

link_libraries(UI_ImGuiBackend)

add_library(UI
        UIManager.cpp UIManager.h
        )
