-- ImportLibConfig_sandbox.lua
-- created on 2019/10/18
-- author @zoloypzuo

-- zelo直接导入Renference/Lua-Game-AI
-- 我们看到premake.lua的两个地方
require "cmake_compiler"

local import_lib_config = ImportLibConfig()
import_lib_config.include_dirs = {
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/",
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/bullet_collision/include/",
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/bullet_dynamics/include/",
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/bullet_linearmath/include/",
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/demo_framework/include",
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/ois/include/",
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/ogre3d/include/",
    "D:/ZeloEngine/Reference/Lua-Game-AI-Programming/src/ogre3d_direct3d9/include/"
}

import_lib_config.lib_names = {
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
    "zzip"
}

import_lib_config.lib_dirs = { string.gsub([[D:\ZeloEngine\Reference\Lua-Game-AI-Programming\lib\x64\debug\]], "\\", "/") }

return import_lib_config