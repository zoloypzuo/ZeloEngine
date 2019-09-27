
-- 3.1
--
print(10%3)		-- 1
print(10.2%3)	-- 1.2


--3.3
v = 3
x = x or v
print(x)		-- 3
y = 2
max = (x>y) and x or y -- max = x>y ? x : y
print(max)		-- 3

--3.6 table中数组索引1开始，也可以手动设置0或负数索引
--成员之间可以用,或;
days = {[-1]="Saturday"; [0]="Sunday", "Monday"}
print(days[-1])
print(days[0])
print(days[1])

