# created on 2021/8/21
# author @zoloypzuo
set(PROJECT_NAME ImGui)

if (WIN32)
    find_package(SDL2 CONFIG REQUIRED)
    link_libraries(SDL2::SDL2 SDL2::SDL2main)
elseif (UNIX)
    find_package(SDL2 CONFIG REQUIRED)
    link_libraries(SDL2::SDL2main SDL2::SDL2-static)
endif ()

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

        backends/imgui_impl_opengl3.cpp backends/imgui_impl_opengl3.h
        backends/imgui_impl_sdl.cpp backends/imgui_impl_sdl.h
        )

target_include_directories(ImGui PUBLIC ./)
