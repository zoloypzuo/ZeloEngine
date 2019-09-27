-- 2.5table
-- 关于table长度
-- #a 使用不恰当可能会有意想不到问题
a = {}
a[-1] = 1
a[0] = 2
a[1] = 3
print(#a)		-- 1

a[3] = 5
print(#a)		-- 1
print(table.maxn(a))	-- 3

for i=1,10 do
	a[5+i] = i+7
end
print(#a)		-- 15
print(table.maxn(a))	-- 15
