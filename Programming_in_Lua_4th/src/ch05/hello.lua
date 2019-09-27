a = {}
for i = 1, 1000 do
    a[i] = i * 2
end

for i = 1, #a do
    print(a[i])
end

for k,v in pairs(a) do
    print(k,v)
end

-- 
t = {}
for line in io.lines() do
    table.insert(t,line)
end
