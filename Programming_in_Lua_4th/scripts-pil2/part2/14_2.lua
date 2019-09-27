--[[14_2.lua
这一节介绍通过_G控制全局变量的访问
只有函数主程序块或c代码允许对新的全局变量进行直接赋值
全局变量如果值为nil再访问时（已经在_G中清除），保存到declaredNames中
如果一定要用全局变量可以用rawset与rawget
]]

-- 提前定义2个函数
function declare (name, initval)
	rawset(_G, name, initval or false)
end
function isDeclared (name)
	--local c = 2	-- 访问错误
	--c = 2			-- 可以使用
	return rawget(_G, name)~=nil
end

-- 确保x=nil也可以起到声明全局变量的作用，不会在其它地方访问的时候报错
local declaredNames = {}

setmetatable(_G, {
	__newindex = function (t, n, v)
		if not declaredNames[n] then
			-- 调试相关内容位于23章
			local w = debug.getinfo(2, "S").what
			--print(w, n, v)
			if w ~= "main" and w ~= "C" then
				error("attempt to write to undeclared variable " .. n, 2)
			end
			declaredNames[n] = true
		end
		rawset(t, n, v)
	end,
	__index = function (_, n)
		if not decalredNames[n] then
			error("attempt to read undeclared variable " .. n, 2)
		else
			return nil
		end
	end,
})

a = 2
b = nil
print(isDeclared("a"))
print(isDeclared("b"))
print(declaredNames["a"])
print(declaredNames["b"])

