# created on 2021/7/26
# author @zoloypzuo
add_library(Parser
        IniReader.cpp IniReader.h
        MeshLoader.cpp MeshLoader.h
        )

target_link_libraries(Parser PRIVATE assimp::assimp)