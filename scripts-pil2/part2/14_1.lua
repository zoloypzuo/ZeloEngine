--14.lua
--string.gmatch用法在20章

function getfield(f)
	local v = _G
	for w in string.gmatch(f, "[%w_]+") do
		v = v[w]
	end
	return v
end

function setfield(f, v)
	local t = _G
	for w, d in string.gmatch(f, "([%w_]+)(%.?)") do
		print(w, d)
		if d=="." then
			t[w] = t[w] or {}
			t = t[w]
		else
			t[w] = v
		end
	end
end

setfield("t1.x2.y3", 10)
print(_G["t1"])
print(t1.x2.y3)
print(getfield("t1.x2.y3"))


