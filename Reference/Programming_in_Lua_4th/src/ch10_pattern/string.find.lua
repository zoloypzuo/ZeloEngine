-- string.find.lua

s = "hello world"
i, j = string.find(s, "hello")  --> 1, 5
-- 拿到索引范围一般用sub获取匹配的字串
string.sub(s, i, j)  --> "hello"