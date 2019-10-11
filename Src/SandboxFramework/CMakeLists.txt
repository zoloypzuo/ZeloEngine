# created on 2019/10/9
# author @zoloypzuo

file(GLOB SRC_LIST Src/*.cpp Inc/*.h)

add_library(SandboxFramework ${SRC_LIST})

target_include_directories(SandboxFramework PRIVATE
        Inc/
        )
