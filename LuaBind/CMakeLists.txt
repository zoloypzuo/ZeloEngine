add_library(LuaBind
        LuaBind.cpp
        Core/LuaBind_Core.cpp
        Core/ECS/LuaBind_Entity.cpp
        Core/Game/LuaBind_Game.cpp
        Core/UI/LuaBind_UI.cpp
        Core/UI/LuaBind_ImGui.cpp

        Sandbox/LuaBind_Sandbox.cpp

        ScriptLib/BitOp.c
        )

target_link_libraries(LuaBind PRIVATE
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
