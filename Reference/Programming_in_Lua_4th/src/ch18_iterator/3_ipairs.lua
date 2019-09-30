function ipairs(t)
    return function(t, i)
        i = i + 1
        local v = t[i]
        if v then
            return i, v
        end
    end, t, 0
end

local t = { 1, 2, 3 }
for k, v in ipairs(t) do
    print(k, v)
end