add_library(LuaBind
        LuaBind.cpp
        Core/LuaBind_Global.cpp
        Core/ECS/LuaBind_Entity.cpp
        Core/Game/LuaBind_Game.cpp
        Core/UI/LuaBind_UI.cpp
        Core/UI/LuaBind_ImGui.cpp

        ScriptLib/BitOp.cpp
        )

target_link_libraries(LuaBind PRIVATE
        GLSLBook
        Craft
        )

target_compile_options(LuaBind PRIVATE -bigobj)  # LuaBind_ImGui.cpp : fatal error C1128
