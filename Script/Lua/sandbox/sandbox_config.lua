-- sandbox_config.lua
-- created on 2022/1/9
-- author @zoloypzuo
local SandboxConfig = Class(function(self, name)
    self.name = name or ""
    self.path = name or ""
    self.desc = ""
end)

return {
    SandboxConfig("Default");
    SandboxConfig("Ch3_SampleGL03_CubeMap");
    SandboxConfig("Ch7_SampleGL01_LargeScene");
    SandboxConfig("Ch10_SampleGL05_Final");
    SandboxConfig("GLSLBook.Bloom");
    SandboxConfig("GLSLBook.Blur");
    SandboxConfig("GLSLBook.Edge");
    SandboxConfig("GLSLBook.ShadowMap");
}