# created on 2021/7/31
# author @zoloypzuo

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