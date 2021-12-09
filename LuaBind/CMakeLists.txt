add_library(LuaBind
        LuaBind.cpp

        ThirdParty/LuaBind_ThirdParty.cpp
        ThirdParty/ImGui/LuaBind_ImGui.cpp
        ThirdParty/ImGui/LuaBind_ImGuiEnum.cpp
        ThirdParty/ImGui/LuaBind_ImGuiWidget.cpp
        ThirdParty/ImGui/LuaBind_ImGuiWindow.cpp
        ThirdParty/LuaBitOp/LuaBind_LuaBitOp.cpp

        Core/LuaBind_Core.cpp
        Core/ECS/LuaBind_Entity.cpp
        Core/Game/LuaBind_Game.cpp
        Core/UI/LuaBind_UI.cpp

        Sandbox/LuaBind_Sandbox.cpp
        )

target_link_libraries(LuaBind PRIVATE
        ImGui
        LuaBitOp
        Engine
        TemplateSandbox
        GLSLBook
        Craft
        GRCookbook
        )

target_include_directories(LuaBind PRIVATE
        ${CMAKE_SOURCE_DIR}/Engine
        ${CMAKE_SOURCE_DIR}/Sandbox
        )

target_compile_options(LuaBind PRIVATE -bigobj)  # LuaBind_ImGui.cpp : fatal error C1128

set_target_properties(LuaBind PROPERTIES FOLDER "LuaBind")
