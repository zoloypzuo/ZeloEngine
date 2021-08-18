# require

默认注册的loader，lua和C dll

```c++
static const lua_CFunction loaders[] =
  {loader_preload, loader_Lua, loader_C, loader_Croot, NULL};

```

package模块初始化loaders，注册require

```c++
LUALIB_API int luaopen_package (lua_State *L) {
  /* create new type _LOADLIB */
  /* create `package' table */
  /* create `loaders' table */
  lua_createtable(L, 0, sizeof(loaders)/sizeof(loaders[0]) - 1);
  /* fill it with pre-defined loaders */
  for (i=0; loaders[i] != NULL; i++) {
    lua_pushcfunction(L, loaders[i]);
    lua_rawseti(L, -2, i+1);
  }
  lua_setfield(L, -2, "loaders");  /* put it in field `loaders' */
  setpath(L, "path", LUA_PATH, LUA_PATH_DEFAULT);  /* set field `path' */
  setpath(L, "cpath", LUA_CPATH, LUA_CPATH_DEFAULT); /* set field `cpath' */
  /* store config information */
  lua_pushliteral(L, LUA_DIRSEP "\n" LUA_PATHSEP "\n" LUA_PATH_MARK "\n"
                     LUA_EXECDIR "\n" LUA_IGMARK);
  return 1;  /* return 'package' table */
}
```

require伪代码
```lua
local function require (name)
    if not package.loaded[name] then -- module not loaded yet?
        local loader = findloader(name)
        if loader == nil then
            error("unable to load module " .. name)
        end
        package.loaded[name] = true -- mark module as loaded
        local res = loader(name) -- initialize moduleloader
        if res ~= nil then
            package.loaded[name] = res
        end
    end
    return package.loaded[name]
end
```

ll_require
遍历loader，做一个fallback
```c++
static int ll_require (lua_State *L) {
  const char *name = luaL_checkstring(L, 1);
  int i;
  lua_settop(L, 1);  /* _LOADED table will be at index 2 */
  lua_getfield(L, LUA_REGISTRYINDEX, "_LOADED");
  lua_getfield(L, 2, name);
  if (lua_toboolean(L, -1)) {  /* is it there? */
    if (lua_touserdata(L, -1) == sentinel)  /* check loops */
      luaL_error(L, "loop or previous error loading module " LUA_QS, name);
    return 1;  /* package is already loaded */
  }
  /* else must load it; iterate over available loaders */
  lua_getfield(L, LUA_ENVIRONINDEX, "loaders");
  if (!lua_istable(L, -1))
    luaL_error(L, LUA_QL("package.loaders") " must be a table");
  lua_pushliteral(L, "");  /* error message accumulator */
  for (i=1; ; i++) {
    lua_rawgeti(L, -2, i);  /* get a loader */
    if (lua_isnil(L, -1))
      luaL_error(L, "module " LUA_QS " not found:%s",
                    name, lua_tostring(L, -2));
    lua_pushstring(L, name);
    lua_call(L, 1, 1);  /* call it */
    if (lua_isfunction(L, -1))  /* did it find module? */
      break;  /* module loaded successfully */
    else if (lua_isstring(L, -1))  /* loader returned error message? */
      lua_concat(L, 2);  /* accumulate it */
    else
      lua_pop(L, 1);
  }
  lua_pushlightuserdata(L, sentinel);
  lua_setfield(L, 2, name);  /* _LOADED[name] = sentinel */
  lua_pushstring(L, name);  /* pass name as argument to module */
  lua_call(L, 1, 1);  /* run loaded module */
  if (!lua_isnil(L, -1))  /* non-nil return? */
    lua_setfield(L, 2, name);  /* _LOADED[name] = returned value */
  lua_getfield(L, 2, name);
  if (lua_touserdata(L, -1) == sentinel) {   /* module did not set a value? */
    lua_pushboolean(L, 1);  /* use true as result */
    lua_pushvalue(L, -1);  /* extra copy to be returned */
    lua_setfield(L, 2, name);  /* _LOADED[name] = true */
  }
  return 1;
}
```