-- sandbox_config.lua
-- created on 2022/1/9
-- author @zoloypzuo
local SandboxConfig = Class(function(self, name)
    self.name = name or ""
    self.path = name or ""
    self.desc = ""
end)

return {
    SandboxConfig("Ch3_SampleGL03_CubeMap");
}