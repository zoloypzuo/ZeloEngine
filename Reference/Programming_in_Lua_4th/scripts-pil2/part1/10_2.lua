io.input("part1/10_2_in.txt")

function allwords ()
	local line = io.read()
	local pos = 1
	return function ()
		while line do
			local s, e = string.find(line, "%w+", pos)
			if s then
				pos = e + 1
				return string.sub(line, s, e)
			else
				line = io.read()
				pos = 1
			end
		end
		return nil
	end
end

function prefix (w1, w2)
	return w1 .. " " .. w2
end

local statetab = {}

function insert (index, value)
	local list = statetab[index]
	if list == nil then
		statetab[index] = {value}
	else
		list[#list+1] = value
	end
end


local N = 2
local MAXGEN = 100
local NOWORD = "\n"

local w1, w2 = NOWORD, NOWORD
for w in allwords() do
	insert(prefix(w1, w2), w)
	w1 = w2; w2 = w;
end

insert(prefix(w1, w2), NOWORD)

for k, v in pairs(statetab) do
	local str = ""
	for i, s in ipairs(v) do
		if i==1 then
			str = s
		else
			str = str .. "," .. s
		end
	end
	print(k, " ", str)
end

w1 = NOWORD; w2 = NOWORD
for i=1, MAXGEN do
	local list = statetab[prefix(w1, w2)]
	local r = math.random(#list)
	local nextword = list[r]
	if nextword == NOWORD then return end
	io.write(nextword, " ")
	w1 = w2; w2 = nextword
end
