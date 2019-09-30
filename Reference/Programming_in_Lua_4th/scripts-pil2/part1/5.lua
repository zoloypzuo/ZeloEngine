
-- . : 用法区别
o = {}
function o.foo(x)
	local v = x
	print(self)		-- nil
end

function o.foo1(self, x)
	local v = x
	print(self)		-- 第一个参数
end

o.foo1(o, 3)
o:foo1(2)

-- 5.1 函数调用只有作为table的最后一个元素时，才会返回所有结果
function foo() end
function foo1() return "a" end
function foo2() return "a", "b" end
t = {foo(), foo(2), 4}	-- {nil, "a", 4}

a = {"hello", "ll"}
-- 等于string.find("hello", "ll")
-- 不等于string.find({"hello", "ll"})
string.find(unpack(a))

-- 5.2 select用法
-- 中文版说法有误，不知道原书是怎么说的，可以参考官方文档
-- select返回的是index及其以后的所有参数，不是第index个
function f(...)
	for i=1, select('#', ...) do
		print(select(i, ...))
	end
end

f(3,4,5,6)


-- 5.3 如果参数只有一个table，则()可以省略

