# created on 2021/8/16
# author @zoloypzuo

set(ImGuiBackendSrc
        ${CMAKE_SOURCE_DIR}/Dep/src/imgui/backends/imgui_impl_opengl3.cpp
        ${CMAKE_SOURCE_DIR}/Dep/src/imgui/backends/imgui_impl_sdl.cpp
        )

add_library(UI
        ${ImGuiBackendSrc}
        Resource/Font.cpp Resource/Font.h
        ImGuiManager.cpp ImGuiManager.h
        )

target_link_libraries(UI PUBLIC OS)
target_link_libraries(UI PRIVATE ImGui)
target_link_libraries(UI PRIVATE unofficial::nativefiledialog::nfd)
