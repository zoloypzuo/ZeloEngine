# created on 2021/7/26
# author @zoloypzuo
# first we compile lua from source
# lua <= sol <= engine object system
add_subdirectory(Lua)
add_subdirectory(ImGui)
add_subdirectory(Optick)
add_subdirectory(Sol2)
add_subdirectory(Whereami)
add_subdirectory(LuaBitOp)
add_subdirectory(TupleUtils)
add_subdirectory(Backward)

set_target_properties(Lua PROPERTIES FOLDER "ThirdParty")
set_target_properties(ImGui PROPERTIES FOLDER "ThirdParty")
set_target_properties(Optick PROPERTIES FOLDER "ThirdParty")
set_target_properties(Sol2 PROPERTIES FOLDER "ThirdParty")
set_target_properties(Whereami PROPERTIES FOLDER "ThirdParty")
set_target_properties(LuaBitOp PROPERTIES FOLDER "ThirdParty")
set_target_properties(TupleUtils PROPERTIES FOLDER "ThirdParty")
set_target_properties(Backward PROPERTIES FOLDER "ThirdParty")
