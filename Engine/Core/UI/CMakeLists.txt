# created on 2021/8/16
# author @zoloypzuo
add_subdirectory(ImGuiBackend)

link_libraries(UI_ImGuiBackend)

add_library(UI
        Resource/Font.cpp Resource/Font.h
        UIManager.cpp UIManager.h
        )
