--this is run outside of the game to put speech files into a consistent order

local file_in = arg[1]
local file_out = arg[2] or file_in .. ".lua"

local function alphatable(in_table, indent)
	indent = indent or 0
	local indentstr = string.rep("\t",indent)
	local inner_indentstr = string.rep("\t",indent+1)
	local items = {}
	for k,v in pairs(in_table) do

		local key = tostring(k)
		if type(k) == "number" then
			key = "["..key.."]"
		end
		
		if type(v) == "string" then
			table.insert(items, string.format("%s%s = %q,", inner_indentstr, key, v))
		elseif type(v) == "table" then
			local str = alphatable(v, indent + 1)
			table.insert(items, string.format("%s%s =\n%s,", inner_indentstr, key, str))
		end
		
		
	end
	table.sort(items)
	table.insert(items, 1, indentstr.."{")
	table.insert(items, indentstr.."}")
	return table.concat(items, "\n")
end


if file_in then

	local str = alphatable(require(file_in))
	str = "return " .. str 
	local file = io.open(file_out, "w")
	file:write(str)
	file:close()
end

--print (alphatable( {b = "ASDASD", a = "ASDASAAA", c="3"} ))
