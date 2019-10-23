-- Prefab.lua
-- 2019年10月7日

require("class")
--require("entityscript")
--PREFABS.LUA

-- 名字
-- 函数
-- 资产列表
-- 深度？
Prefab = Class(function(self, name, fn, assets, deps)
    self.name = name or ""
    self.path = name or nil
    self.name = string.sub(name, string.find(name, "[^/]*$"))
    self.desc = ""
    self.fn = fn
    self.assets = assets or {}
    self.deps = deps or {}
end)

function Prefab:__tostring()
    return string.format("Prefab %s - %s", self.name, self.desc)
end

-- 类型
-- 文件
-- 参数
Asset = Class(function(self, type, file, param)
    self.type = type
    self.file = file
    self.param = param
end)