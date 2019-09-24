# created on 2019/9/24
# author @zoloypzuo

file(GLOB SRC_LIST *.cpp *.h)

add_library(LuaModule ${SRC_LIST})