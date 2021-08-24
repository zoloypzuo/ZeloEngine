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