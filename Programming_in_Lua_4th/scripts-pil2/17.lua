a = {}
b = {__mode = "k"}
setmetatable(a, b)
key = {a=3}
key1 = "a"
a[key] = 1
key = {}
key1 = "b"
a[key] = 2
collectgarbage()
for k, v in pairs(a) do print(v) end
