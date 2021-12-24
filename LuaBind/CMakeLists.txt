add_library(LuaBind
        LuaBind_Main.cpp
        LuaBind_Boot.cpp

        Config/LuaBind_Config.cpp

        ThirdParty/LuaBind_ThirdParty.cpp
        ThirdParty/Glm/LuaBind_Glm.cpp
        ThirdParty/ImGui/LuaBind_ImGui.cpp
        ThirdParty/ImGui/LuaBind_ImGuiWidget.cpp
        ThirdParty/ImGui/LuaBind_ImGuiWindow.cpp
        ThirdParty/LuaBitOp/LuaBind_LuaBitOp.cpp

        Core/LuaBind_Core.cpp
        Core/LuaBind_Entity.cpp
        Core/LuaBind_RHI.cpp
        Core/LuaBind_Scene.cpp
        Core/LuaBind_UI.cpp

        Renderer/LuaBind_Renderer.cpp

        Sandbox/LuaBind_Sandbox.cpp
        )

target_link_libraries(LuaBind PRIVATE
        LuaScript
        ImGui
        LuaBitOp
        Engine
        TemplateSandbox
        GLSLBook
        )

target_include_directories(LuaBind PRIVATE
        ${CMAKE_SOURCE_DIR}/Engine
        ${CMAKE_SOURCE_DIR}/Sandbox
        )

target_compile_options(LuaBind PRIVATE -bigobj)  # LuaBind_ImGui.cpp : fatal error C1128

set_target_properties(LuaBind PROPERTIES FOLDER "LuaBind")
