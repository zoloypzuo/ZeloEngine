-- ui_util
-- created on 2021/8/24
-- author @zoloypzuo
function ParseFlags(enumTable, flag)
    local names = {}
    for name, val in pairs(enumTable) do
        if bit.band(flag, val) ~= 0 then
            names[#names + 1] = name
        end
    end
    return names
end

function GenFlagFromTable(imguiFlags, setting, default)
    if default then
        -- use default
        for k, v in pairs(default) do
            if setting[k] ~= nil then
                setting[k] = v
            end
        end
    end

    local flag = 0
    for k, v in pairs(setting) do
        assert(imguiFlags[k], "flag not exists")
        if v then
            flag = bit.bor(flag, imguiFlags[k])
        end
    end
    return flag
end
