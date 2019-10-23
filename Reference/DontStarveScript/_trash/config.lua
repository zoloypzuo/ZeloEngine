require "class"

local Config = Class(function(self, options)
    self.options = {}
    if options then
        self:SetOptions(options)
    end
end)

-- 深拷贝一份选项
function Config:SetOptions(options)
    for k, v in pairs(options) do
        self.options[k] = v
    end
end

-- 一个选项是否开启
function Config:IsEnabled(option)
    return self.options[option]
end

-- 开启设为true
function Config:Enable(option)
    self.options[option] = true
end

-- 关闭设为nil
function Config:Disable(option)
    self.options[option] = nil
end

-- 打印选项
function Config:__tostring()
    local str = {}
    table.insert(str, "PLATFORM CONFIGURATION OPTIONS")
    for k, v in pairs(self.options) do
        table.insert(str, string.format("%s = %s", tostring(k), tostring(v)))
    end

    return table.concat(str, "\n")
end


-------------------------------------------------

local defaults = {
    hide_vignette = false,
    force_netbookmode = false,
}

local platform_overrides = {

    NACL = {
        force_netbookmode = true,
    },
    ANDROID = {
        hide_vignette = true,
        force_netbookmode = true,
    },
    IOS = {
        hide_vignette = true,
        force_netbookmode = true,
    },
}

-- 先使用默认选项（在上面）
-- 如果有，用平台重载的选项覆盖
TheConfig = Config(defaults)
if platform_overrides[PLATFORM] then
    TheConfig:SetOptions(platform_overrides[PLATFORM])
end


