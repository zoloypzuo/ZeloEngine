-- pluginable_mixin
-- created on 2021/8/25
-- author @zoloypzuo
local IPlugin = {
    Execute = nil; -- function
    userData = nil; -- void*
}

local PluginableMixin = Mixin(function(self)
    self.plugins = {}  -- List[IPlugin]
end)

function PluginableMixin:AddPlugin(type_, ...)
    assert(type(type_) == "table", "T should derive from IPlugin")
    local inst = type_(...)
    self.plugins[#self.plugins + 1] = inst
    return inst
end

function PluginableMixin:GetPlugin(type_)
    -- TODO
end

function PluginableMixin:ExecutePlugins()
    for i, plugin in ipairs(self.plugins) do
        plugin:Execute()
    end
end

function PluginableMixin:RemoveAllPlugins()
    self.plugins = {}
end

return PluginableMixin