require("class")
--require("entityscript")
--PREFABS.LUA

Prefab = Class( function(self, name, fn, assets, deps)
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

Asset = Class( function(self, type, file)
    self.type = type
    self.file = file
end)