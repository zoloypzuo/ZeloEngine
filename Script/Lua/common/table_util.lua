-- table_util
-- created on 2021/8/22
-- author @zoloypzuo
function table.clear(t)
    for k, v in pairs(t) do
        t[k] = nil
    end
end

function table.contains(table, element)
    if table == nil then
        return false
    end

    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

function table.containskey(table, target_key)
    if table == nil then
        return false
    end

    for key, _ in pairs(table) do
        if key == target_key then
            return true
        end
    end

    return false
end

-- only for indexed tables!
function table.reverse (tab)
    local size = #tab
    local newTable = {}

    for i, v in ipairs(tab) do
        newTable[size - i] = v
    end

    return newTable
end

-- RemoveByValue only applies to array-type tables
function RemoveByValue(t, value)
    if t then
        for i, v in ipairs(t) do
            if v == value then
                table.remove(t, i)
            end
        end
    end
end

function GetTableSize(table)
    local numItems = 0
    if table ~= nil then
        for k, v in pairs(table) do
            numItems = numItems + 1
        end
    end
    return numItems
end

function GetRandomItem(choices)
    local numChoices = GetTableSize(choices)

    if numChoices < 1 then
        return
    end

    local choice = math.random(numChoices) - 1

    local picked = nil
    for k, v in pairs(choices) do
        picked = v
        if choice <= 0 then
            break
        end
        choice = choice - 1
    end
    assert(picked ~= nil)
    return picked
end

function GetRandomItemWithIndex(choices)
    local choice = math.random(GetTableSize(choices)) - 1

    local idx = nil
    local item = nil

    for k, v in pairs(choices) do
        idx = k
        item = v
        if choice <= 0 then
            break
        end
        choice = choice - 1
    end
    assert(idx ~= nil and item ~= nil)
    return idx, item
end

-- Made to work with (And return) array-style tables
function PickSome(num, choices)
    local l_choices = choices
    local ret = {}
    for i = 1, num do
        local choice = math.random(#l_choices)
        table.insert(ret, l_choices[choice])
        table.remove(l_choices, choice)
    end
    return ret
end

function PickSomeWithDups(num, choices)
    local l_choices = choices
    local ret = {}
    for i = 1, num do
        local choice = math.random(#l_choices)
        table.insert(ret, l_choices[choice])
    end
    return ret
end

-- concatenate two array-style tables
function JoinArrays(...)
    local ret = {}
    for i, array in ipairs({ ... }) do
        for j, val in ipairs(array) do
            table.insert(ret, val)
        end
    end
    return ret
end

-- merge two array-style tables, only allowing each value once
function ArrayUnion(...)
    local ret = {}
    for i, array in ipairs({ ... }) do
        for j, val in ipairs(array) do
            if not table.contains(ret, val) then
                table.insert(ret, val)
            end
        end
    end
    return ret
end

-- merge two map-style tables, overwriting duplicate keys with the latter map's value
function MergeMaps(...)
    local ret = {}
    for i, map in ipairs({ ... }) do
        for k, v in pairs(map) do
            ret[k] = v
        end
    end
    return ret
end

-- Adds 'addition' to the end of 'orig', 'mult' times.
-- ExtendedArray({"one"}, {"two","three"}, 2) == {"one", "two", "three", "two", "three" }
function ExtendedArray(orig, addition, mult)
    local ret = {}
    for k, v in pairs(orig) do
        ret[k] = v
    end
    mult = mult or 1
    for i = 1, mult do
        table.insert(ret, addition)
    end
    return ret
end

function GetRandomKey(choices)
    local choice = math.random(GetTableSize(choices)) - 1

    local picked = nil
    for k, v in pairs(choices) do
        picked = k
        if choice <= 0 then
            break
        end
        choice = choice - 1
    end
    assert(picked)
    return picked
end

function PrintTable(tab)
	local str = {}
	
	local function internal(tab, str, indent)
		for k,v in pairs(tab) do
			if type(v) == "table" then
				table.insert(str, indent..tostring(k)..":\n")
				internal(v, str, indent..' ')
			else
				table.insert(str, indent..tostring(k)..": "..tostring(v).."\n")
			end
		end
	end
	
	internal(tab, str, '')
	return table.concat(str, '')
end
