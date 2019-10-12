# created on 2019/10/9
# author @zoloypzuo

file(GLOB SRC_LIST Src/*.cpp Inc/*.h
        Inc/OGRE/*.h
        Inc/OGRE/Bites/*h
        )

add_library(SandboxFramework ${SRC_LIST})

target_include_directories(SandboxFramework PRIVATE
        Inc/
        Inc/OGRE
        Inc/OGRE/Bites
        )
