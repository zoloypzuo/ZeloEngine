# created on 2021/8/21
# author @zoloypzuo
set(ImGuiSrcDir ${CMAKE_SOURCE_DIR}/Dep/src/imgui)
file(GLOB ImGuiSrc ${ImGuiSrcDir}/*.h ${ImGuiSrcDir}/*.cpp)

add_library(ImGui ${ImGuiSrc})

target_include_directories(ImGui PUBLIC ${ImGuiSrcDir})
