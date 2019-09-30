function getvarvalue(name)
    local value, found

    for i=1, math.huge do
	local n, v = debug.getlocal(2, i)
	if not n then break end
	if n==name then
	    value = v
	    found = true
	end
    end

    if found then return value end

    local func = debug.getinfo(2, "f").func
    for i=1, math.huge do
	local n, v = debug.getupvalue(func, i)
	if not n then break end
	if n==name then return v end
    end

    return getfenv(func)[name]
end

function newCounter()
    local i=0
    return function()
	i=i+1
	local b = i
	print("varvalue:")
	print(getvarvalue("i"))
	return i
    end
end

c1 = newCounter()
print(c1())
print(c1())
