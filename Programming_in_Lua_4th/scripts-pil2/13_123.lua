Set = {}
local mt = {}

function Set.new(l)
	local set = {}
	setmetatable(set, mt)
	for _, v in ipairs(l) do set[v] = true end
	return set
end

function Set.union(a, b)
	local res = Set.new{}
	for k in pairs(a) do res[k] = true end;
	for k in pairs(b) do res[k] = true end;
	return res;
end

function Set.intersection(a, b)
	local res = Set.new{}
	for k in pairs(a) do
		res[k] = b[k]
	end
	return res
end

function Set.tostring(set)
	local l = {}
	for e in pairs(set) do
		l[#l+1] = e
	end
	return "{" .. table.concat(l, ", ") .. "}"
end

function Set.print(s)
	print(Set.tostring(s))
end

mt.__add = Set.union
mt.__mul = Set.intersection
mt.__tostring = Set.tostring
mt.__le = function(a, b)
	for k in pairs(a) do
		if not b[k] then return false end
	end
	return true
end
mt.__lt= function(a, b)
	return a<=b and not(b<=a)
end
mt.__eq = function(a, b)
	return a<=b and b<=a
end

s1 = Set.new{10, 20, 30, 50}
s2 = Set.new{30, 1}
s3 = s1+s2
print(s3)
s3 = s1*s2
print(s3)
s4 = Set.new{2, 4}
s5 = Set.new{4, 10, 2}
print(s4<=s5)
print(s4<s5)
print(s4>s5)
print(s4==s5*s4)
