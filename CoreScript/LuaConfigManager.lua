-- LuaConfigManager.lua
-- created on 2019/10/18
-- author @zoloypzuo
--
-- lua代码加载lua配置
--
-- 简单的辅助

-- 配置文件的命名规则是“类型+下划线+对象名字”
-- 这个配置类就是将整个路径拆为目录，类型名，对象名
-- 配置文件总是返回一个表，所以我们dofile它返回即可
LuaConfigManager = Class(function(self, config_dir, cls_prefix)
    self.config_dir = config_dir
    self.cls_prefix = cls_prefix
end)

function LuaConfigManager:load_config(name)
    local path = self.config_dir .. self.cls_prefix .. "_" .. name .. ".lua"
    return dofile(path)
end