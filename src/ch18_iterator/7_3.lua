-- 7.3

local function getnext(list, node)
    if not node then
	return list
    else
	return node.next
    end
end

function traverse(list)
    return getnext, list, nil
end

list = nil

for line in io.lines("7_1_1.lua") do
    list = {val = line, next = list}
end

for node in traverse(list) do
    print(node.val)
end
