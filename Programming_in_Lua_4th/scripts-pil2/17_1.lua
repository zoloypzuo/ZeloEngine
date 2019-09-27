function loadstring(s)
	local b = {a=s}
	return b
end


local results = {}
setmetatable(results, {__mode="v"})

function mem_loadstring(s)
	local res = results[s]
	if res==nil then
		res = assert(loadstring(s))
		results[s] = res
	end
	return res
end

mem_loadstring("a1")
mem_loadstring("a2")
inuse = mem_loadstring("a1")

collectgarbage()

for k, v in pairs(results) do print(v) end

--颜色的例子跟上面的差不多
function createRGB(r, g, b)
	local key = r .."-" .. g .. "-" .. b
	local color = results[key]
	if color==nil then
		color = {red=r, green=g, blue=b}
		results[key] = color
	end
	return color
end
