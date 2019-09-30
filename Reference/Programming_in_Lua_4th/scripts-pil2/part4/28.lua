local metaarray = getmetatable(array.new(1))
metaarray.__index = array.get
metaarray.__newindex = array.set
metaarray.__len = array.size
a = array.new(1000)
a[10] = true
print(a[10])
print(#a)
