--[[14_3.lua
]]

a = 1			-- _G.a
local newgt = {}
setmetatable(newgt, {__index = _G})
setfenv(1, newgt)
print(a)		-- 1
a = 10			-- newgt.a
print(a)		-- 10
print(newgt.a)	-- 10
print(_G.a)		-- 1
_G.a = 20		-- _G.a
print(_G.a)		-- 20

-- 由于在同一个文件中，一下代码环境 仍然为newgt
print("")
function factory ()
	return function ()
		return b
	end
end

b = 3
f1 = factory()
f2 = factory()
print(f1())			-- 3
print(f2())			-- 3
setfenv(f1, {b=10})
print(f1())			-- 10
print(f2())			-- 3

