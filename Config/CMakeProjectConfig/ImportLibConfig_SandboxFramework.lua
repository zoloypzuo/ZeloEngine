-- ImportLibConfig_SandboxFramework.lua
-- created on 2019/10/18
-- author @zoloypzuo

-- zelo直接导入Renference/Lua-Game-AI
-- 我们看到premake.lua的两个地方

DxHeaderDir = [[C:/Program Files (x86)/Microsoft DirectX SDK (June 2010)/Include]]
DxLibx64Dir = [[C:/Program Files (x86)/Microsoft DirectX SDK (June 2010)/Lib/x64]]
DxLibNames = {
    "d3d9",
    "dinput8",
    "dxguid",
    "d3dx9",
    "DxErr",
    --"vcruntimed.lib",
    --"ucrtd.lib",
    --"libucrt.lib",
    --"libucrtd.lib"
}

local import_lib_config = ImportLibConfig()
import_lib_config.include_dirs = List {
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/",
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/lua/include/",
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/bullet_collision/include/",
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/bullet_dynamics/include/",
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/bullet_linearmath/include/",
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/demo_framework/include",
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/ois/include/",
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/ogre3d/include/",
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/ogre3d_direct3d9/include/",
    DxHeaderDir
}:map(cmake_string)

import_lib_config.lib_names = List {
    "bullet_collision",
    "bullet_dynamics",
    "bullet_linearmath",
    "demo_framework",
    "detour",
    "freeimage",
    "freetype",
    "gorilla_audio",
    "libjpeg",
    "libogg",
    "libopenjpeg",
    "libpng",
    "libraw",
    "libtiff4",
    "libvorbis",
    "lua",
    "ogre3d",
    "ogre3d_direct3d9",
    "ogre3d_gorilla",
    "ogre3d_particlefx",
    "ogre3d_procedural",
    "ois",
    "openexr",
    "opensteer",
    "recast",
    "zlib",
    "zzip",
    --
    "d3d9",
    "dinput8",
    "dxguid",
    "d3dx9",
    "DxErr",
}

import_lib_config.lib_dirs = List {
    string.gsub([[D:\ZeloEngine\Reference\Lua-Game-AI-Programming\lib\x64\debug\]], "\\", "/"),
    DxLibx64Dir }:map(cmake_string)

return import_lib_config