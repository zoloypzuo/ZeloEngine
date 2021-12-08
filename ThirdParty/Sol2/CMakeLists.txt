add_library(Sol2 INTERFACE)

target_include_directories(Sol2 INTERFACE include)
target_compile_definitions(Sol2 INTERFACE
        SOL_ALL_SAFETIES_ON  # sol enable safety check
        SOL_NO_LUA_HPP # sol link to the right lua header
        )
target_link_libraries(Sol2 INTERFACE Lua)