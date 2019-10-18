-- ImportLibConfig_ZeloEngine.lua
-- created on 2019/10/18
-- author @zoloypzuo

local external_dir = "External/"
local project_source_dir = cmake_variable "PROJECT_SOURCE_DIR"
local include_dirs = {
    project_source_dir .. "Src/LuaConfig/CppConfigClass_Generated",
    project_source_dir .. "Src/Common"
}

local lib_dirs = { "Lib/Win32Debug/" }
local lib_names = {
    "Common",
}

return ImportLibConfig(include_dirs, lib_dirs, lib_names)