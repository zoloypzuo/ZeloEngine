# created on 2021/8/21
# author @zoloypzuo
set(PROJECT_NAME ImGui)

add_library(ImGui
        imconfig.h
        imgui.cpp
        imgui.h
        imgui_demo.cpp
        imgui_draw.cpp
        imgui_internal.h
        imgui_tables.cpp
        imgui_widgets.cpp
        imstb_rectpack.h
        imstb_textedit.h
        imstb_truetype.h
        )

target_include_directories(ImGui PUBLIC ./)
