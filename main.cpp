#include "ZeloPreCompiledHeader.h"
#include "Zelo.h"
#include "MyGame.h"
#include "sol/sol.hpp"

extern "C" {
extern int luaopen_Zelo(lua_State *L);
}

int main() {
    sol::state lua;
    lua.open_libraries(sol::lib::package, sol::lib::base);

    lua.require("Zelo", luaopen_Zelo);

    lua.script(R"(
    Zelo.Engine():start()
)");

    //Engine engine(new MyGame());
    //engine.start();
    return 0;
}