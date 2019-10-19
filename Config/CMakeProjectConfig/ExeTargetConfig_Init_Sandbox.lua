-- ExeTargetConfig_Init_Sandbox.lua
-- created on 2019/10/18
-- author @zoloypzuo


local self = ExeTargetConfig()
self.name = "Init_Sandbox"
self.import_libs = List { "SandboxFramework", "ZeloEngine" }
self.dir = "Example/Init_Sandbox"
return self