function values(t)
    local i = 0
    return function()
        i = i + 1;
        return t[i]
    end
end

t = { 1, 2, 3 }
iter = values(t)

for element in values(t) do
    print(element)
end
