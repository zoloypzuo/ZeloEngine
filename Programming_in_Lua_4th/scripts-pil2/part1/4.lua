
-- 4.1
x, y = 2, 3
x, y = y, x	-- 交换变量
print(x, y)


-- 4.2
do
	local a = 2
	b = 3
end

local print = print	-- 加快程序执行速度
print(_G["a"])	-- nil
print(_G["b"])	-- 3


-- 4.3
for i=1,3 do
end

print(_G["i"])		-- nil

