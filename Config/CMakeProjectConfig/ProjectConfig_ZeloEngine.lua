-- ProjectConfig_ZeloEngine.lua
-- created on 2019/10/18
-- author @zoloypzuo

local self = ProjectConfig()
self.name = "ZeloEngine"
self.lib_targets = List { "Common" }
self.exe_targets = List { "Init_Sandbox" }
self.compile_definitions = List {
    "UNICODE",
    "NOMINMAX", -- # see also github issue #116
}
self.include_dirs = List {
    "Src/LuaConfig/CppConfigClass_Generated",
    "Src/Common"
}
self.link_libs = List {

}
return self