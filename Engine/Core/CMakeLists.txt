# created on 2021/6/2
# author @zoloypzuo

add_subdirectory(Controller)
add_subdirectory(ECS)
add_subdirectory(Scene)
add_subdirectory(Interface)
add_subdirectory(LogM)
add_subdirectory(LuaScript)
add_subdirectory(Math)
add_subdirectory(OS)
add_subdirectory(Parser)
add_subdirectory(Resource)
add_subdirectory(RHI)
add_subdirectory(UI)

set_target_properties(Controller PROPERTIES FOLDER "Core")
set_target_properties(ECS PROPERTIES FOLDER "Core")
set_target_properties(Scene PROPERTIES FOLDER "Core")
set_target_properties(Interface PROPERTIES FOLDER "Core")
set_target_properties(LogM PROPERTIES FOLDER "Core")
set_target_properties(LuaScript PROPERTIES FOLDER "Core")
set_target_properties(Math PROPERTIES FOLDER "Core")
set_target_properties(OS PROPERTIES FOLDER "Core")
set_target_properties(Parser PROPERTIES FOLDER "Core")
set_target_properties(Resource PROPERTIES FOLDER "Core")
set_target_properties(RHI PROPERTIES FOLDER "Core")
set_target_properties(UI PROPERTIES FOLDER "Core")

add_library(Core INTERFACE)
target_include_directories(Core INTERFACE ${CMAKE_SOURCE_DIR}/Engine)
target_link_libraries(Core INTERFACE
        Controller
        ECS
        Scene
        Interface
        LogM
        LuaScript
        Math
        OS
        Parser
        Resource
        RHI
        UI
        )