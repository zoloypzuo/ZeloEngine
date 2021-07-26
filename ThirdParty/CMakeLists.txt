# created on 2021/7/26
# author @zoloypzuo
# first we compile lua from source
# lua <= sol <= engine object system
add_subdirectory(Lua)

set_target_properties(Lua PROPERTIES FOLDER "ThirdParty")
