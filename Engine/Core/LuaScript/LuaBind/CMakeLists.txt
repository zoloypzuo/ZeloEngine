# created on 2021/7/31
# author @zoloypzuo

link_libraries(GLSLBook)  # TODO
add_library(LuaBind
        LuaBind.cpp
        Core/LuaBind_Global.cpp
        Core/ECS/LuaBind_Entity.cpp
        Core/Game/LuaBind_Game.cpp
        Core/UI/LuaBind_UI.cpp
        Core/UI/LuaBind_ImGui.cpp

        ScriptLib/BitOp.cpp
        )