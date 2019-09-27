function foo(a, b)
    local x
    do local c = a - b end
    local a = 1
    while true do
	local name, value = debug.getlocal(1, a)
	if not name then break end
	print(name, value)
	a = a + 1
    end
end

foo(10, 20)
