Window = {}
Window.prototype = {x=0, y=0, width=100, height=100}
Window.mt = {}
function Window.new(o)
	setmetatable(o, Window.mt)
	return o
end

--[[
Window.mt.__index = function(table, key)
	return Window.prototype[key]
end
]]

Window.mt.__index = Window.prototype

w = Window.new{x=10, y=20}
print(w.width)
print(w["width"])

