require"class"

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function Dist2dSq(p1, p2) 
    local dx = p1.x - p2.x
    local dy = p1.y - p2.y
    return dx*dx + dy*dy
end

function DistPointToSegment2dSq(p, v1, v2) 
    local l2 = Dist2dSq(v1, v2)
    if (l2 == 0) then
        return Dist2dSq(p, v1)
    end
    local t = ((p.x - v1.x) * (v2.x - v1.x) + (p.y - v1.y) * (v2.y - v1.y)) / l2
    if (t < 0) then
        return Dist2dSq(p, v1)
    end
    if (t > 1) then
        return Dist2dSq(p, v2)
    end
    return Dist2dSq(p, {x = v1.x + t * (v2.x - v1.x), y =v1.y + t * (v2.y - v1.y)});
end

function DumpTableXML(t, name)
    name = name or ""
    function dumpinternal(t, outstr, indent)
        for key, value in pairs(t) do
            if type(value) == "table" then
                table.insert(outstr,indent.."<table name='"..tostring(key).."'>\n")
                dumpinternal(value, outstr, indent.."\t")
                table.insert(outstr, indent.."</table>\n")
            else
                table.insert(outstr, indent.."<"..type(value).." name='"..tostring(key).."' val='"..tostring(value).."'/>\n")
            end
        end
    end
    outstr = {"<table name='"..name.."'>\n"}
    dumpinternal(t, outstr, "\t")
    table.insert(outstr, "</table>")
    return table.concat(outstr)
end

function DebugSpawn(prefab)
    if TheSim and TheInput then
        TheSim:LoadPrefabs({prefab})
        local inst = SpawnPrefab(prefab)
        if inst then
            SuUsed("c_spawn_" .. prefab , true)
	        inst.Transform:SetPosition(TheInput:GetWorldPosition():Get())
			return inst
	    end
	end
end

function print_table(t, highlight)
    print ("\n\n\n\n========================================================\n\n")

    if highlight ~= nil then
        print (highlight)
    end

    if t == nil then
        print ("The provided table is nil")
    elseif (type(t) ~= "table") then
        print ("The provided value is not a table:")
        print (t)
    else
        print ("Size: " .. #t)
        print ("Content: ")

        for pos,val in pairs(t) do
            print (string.format("Key: [ %s ] \t Value: [ %s ]", tostring(pos), tostring(val)))
        end
    end

    print ("\n\n========================================================\n\n\n\n")
end

function SpawnAt(prefab, loc, scale, offset)

    offset = ToVector3(offset) or Vector3(0,0,0)

    if not loc or not prefab then return end

    prefab = (prefab.GUID and prefab.prefab) or prefab

    local spawn = SpawnPrefab(prefab)
    local pos = nil

    if loc.prefab then
        pos = loc:GetPosition()
    else
        pos = loc
    end

    if spawn and pos then
        pos = pos + offset
        spawn.Transform:SetPosition(pos:Get())
        if scale then
            scale = ToVector3(scale)
            spawn.Transform:SetScale(scale:Get())
        end
        return spawn
    end
end

function string:split(sep)
        local sep, fields = sep or ":", {}
        local pattern = string.format("([^%s]+)", sep)
        self:gsub(pattern, function(c) fields[#fields+1] = c end)
        return fields
end


local Chars = {}
for Loop = 0, 255 do
   Chars[Loop+1] = string.char(Loop)
end
local String = table.concat(Chars)

local Built = {['.'] = Chars}

local AddLookup = function(CharSet)
   local Substitute = string.gsub(String, '[^'..CharSet..']', '')
   local Lookup = {}
   for Loop = 1, string.len(Substitute) do
       Lookup[Loop] = string.sub(Substitute, Loop, Loop)
   end
   Built[CharSet] = Lookup

   return Lookup
end

function string.random(Length, CharSet)
   -- Length (number)
   -- CharSet (string, optional); e.g. %l%d for lower case letters and digits

   local CharSet = CharSet or '.'

   if CharSet == '' then
      return ''
   else
      local Result = {}
      local Lookup = Built[CharSet] or AddLookup(CharSet)
      local Range = table.getn(Lookup)

      for Loop = 1,Length do
         Result[Loop] = Lookup[math.random(1, Range)]
      end

      return table.concat(Result)
   end
end

function table.clear(t)
    for k,v in pairs(t) do
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

    for key,_ in pairs(table) do
        if key == target_key then
            return true
        end
    end

    return false
end

-- only for indexed tables!
function table.reverse ( tab )
    local size = #tab
    local newTable = {}
 
    for i,v in ipairs ( tab ) do
        newTable[size-i] = v
    end
 
    return newTable
end

-- RemoveByValue only applies to array-type tables
function RemoveByValue(t, value)
    if t then
        for i,v in ipairs(t) do 
            if v == value then
                table.remove(t, i)
            end
        end
    end
end

function GetTableSize(table)
	local numItems = 0
	if table ~= nil then
		for k,v in pairs(table) do
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

 	local choice = math.random(numChoices) -1

 	local picked = nil
 	for k,v in pairs(choices) do
 		picked = v
 		if choice<= 0 then
 			break
 		end
 		choice = choice -1
 	end
 	assert(picked~=nil)
	return picked
end

function GetRandomItemWithIndex(choices)
    local choice = math.random(GetTableSize(choices)) -1
    
    local idx = nil
    local item = nil

    for k,v in pairs(choices) do
        idx = k
        item = v
        if choice<= 0 then
            break
        end
        choice = choice -1
    end
    assert(idx~=nil and item~=nil)
    return idx, item
end

-- Made to work with (And return) array-style tables
function PickSome(num, choices)
	local l_choices = choices
	local ret = {}
	for i=1,num do
		local choice = math.random(#l_choices)
		table.insert(ret, l_choices[choice])
		table.remove(l_choices, choice)
	end
	return ret
end

function PickSomeWithDups(num, choices)
    local l_choices = choices
    local ret = {}
    for i=1,num do
        local choice = math.random(#l_choices)
        table.insert(ret, l_choices[choice])       
    end
    return ret
end

-- concatenate two array-style tables
function JoinArrays(...)
	local ret = {}
	for i,array in ipairs({...}) do
		for j,val in ipairs(array) do
			table.insert(ret, val)
		end
	end
	return ret
end

-- merge two array-style tables, only allowing each value once
function ArrayUnion(...)
	local ret = {}
	for i,array in ipairs({...}) do
		for j,val in ipairs(array) do
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
	for i,map in ipairs({...}) do
		for k,v in pairs(map) do
			ret[k] = v
		end
	end
	return ret
end

-- Adds 'addition' to the end of 'orig', 'mult' times.
-- ExtendedArray({"one"}, {"two","three"}, 2) == {"one", "two", "three", "two", "three" }
function ExtendedArray(orig, addition, mult)
	local ret = {}
	for k,v in pairs(orig) do
		ret[k] = v
	end
	mult = mult or 1
	for i=1,mult do
		table.insert(ret,addition)
	end
	return ret
end

function GetRandomKey(choices)
 	local choice = math.random(GetTableSize(choices)) -1
 	
 	local picked = nil
 	for k,v in pairs(choices) do
 		picked = k
 		if choice<= 0 then
 			break
 		end
 		choice = choice -1
 	end
 	assert(picked)
	return picked
end

function GetRandomWithVariance(baseval, randomval)
    return baseval + (math.random()*2*randomval - randomval)
end

function GetRandomMinMax(min, max)
    return min + math.random()*(max - min)
end

function distsq(v1, v2, v3, v4)

    -- PLEASE FORGIVE US! WE NEVER MEANT FOR IT TO END THIS WAY!

    assert(v1, "Something is wrong: v1 is nil stale component reference?")
    assert(v2, "Something is wrong: v2 is nil stale component reference?")
    
    --special case for 2dvects passed in as numbers
    if v1 and v2 and v3 and v4 then
        local dx = v1-v3
        local dy = v2-v4
        return dx*dx + dy*dy
    end

    local dx = (v1.x or v1[1]) - (v2.x or v2[1])
    local dy = (v1.y or v1[2]) - (v2.y or v2[2])
    local dz = (v1.z or v1[3]) - (v2.z or v2[3])
    return dx*dx+dy*dy+dz*dz
end

local memoizedFilePaths = {}

-- look in package loaders to find the file from the root directories
-- this will look first in the mods and then in the data directory
function resolvefilepath( filepath )
    if memoizedFilePaths[filepath] then
        return memoizedFilePaths[filepath]
    end
	local resolved = softresolvefilepath(filepath)
	assert(resolved ~= nil, "Could not find an asset matching "..filepath.." in any of the search paths.")
    memoizedFilePaths[filepath] = resolved
    return resolved
end

function softresolvefilepath(filepath)
	if PLATFORM == "NACL" or PLATFORM == "PS4" then
		return filepath -- it's already absolute, so just send it back
	end

	-- on PC platforms, search all the possible paths

	-- mod folders don't have "data" in them, so we strip that off if necessary. It will
	-- be added back on as one of the search paths.
	local filepath = string.gsub(filepath, "^/", "")

	local searchpaths = package.path
    for path in string.gmatch(searchpaths, "([^;]+)") do
        local filename = string.gsub(path, "scripts\\%?%.lua", filepath)
        filename = string.gsub(filename, "\\", "/")
		--print("looking for: "..filename.." ("..filepath..")")
		if not kleifileexists or kleifileexists(filename) then
			--print("found it! "..filename)
            return filename
        end
    end
	-- as a last resort see if the file is an already correct path (incase this asset has already been processed)
	if not kleifileexists or kleifileexists(filepath) then
		--print("found it in it's actual path! "..filepath)
		return filepath
	end

	return nil
end

-------------------------MEMREPORT

local global_type_table = nil

local function type_name(o)
	if global_type_table == nil then
		global_type_table = {}
		for k,v in pairs(_G) do
			global_type_table[v] = k
		end
		global_type_table[0] = "table"
	end
	local mt = getmetatable(o)
	if mt then
		return global_type_table[mt] or "table"
	else
		return type(o) --"Unknown"
	end
end


local function count_all(f)
	local seen = {}
	local count_table
	count_table = function(t)
		if seen[t] then return end
		f(t)
		seen[t] = true
		for k,v in pairs(t) do
			if type(v) == "table" then
				count_table(v)
			else
				f(v)
            end
		end
	end
	count_table(_G)
end

function isnan(x) return x ~= x end
math.inf = 1/0 
function isinf(x) return x == math.inf or x == -math.inf end
function isbadnumber(x) return isinf(x) or isnan(x) end

local function type_count()
	local counts = {}
	local enumerate = function (o)
		local t = type_name(o)
		counts[t] = (counts[t] or 0) + 1
	end
	count_all(enumerate)
	return counts
end
   
function mem_report()
    local tmp = {}
    
    for k,v in pairs(type_count()) do 
        table.insert(tmp, {num=v, name=k})
    end
    table.sort(tmp, function(a,b) return a.num > b.num end)
    local tmp2 = {"MEM REPORT:\n"}
    for k,v in ipairs(tmp) do
        table.insert(tmp2, tostring(v.num).."\t"..tostring(v.name))
    end
    
    print (table.concat(tmp2,"\n"))
end

-------------------------MEMREPORT



function weighted_random_choice(choices)

    local function weighted_total(choices)
        local total = 0
        for choice, weight in pairs(choices) do
            total = total + weight
        end
        return total
    end

    local threshold = math.random(0, weighted_total(choices))
    local last_choice
    for choice, weight in pairs(choices) do
        threshold = threshold - weight
        if threshold <= 0 then return choice end
        last_choice = choice
    end
    return last_choice
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


-- make environment
local env = {  -- add functions you know are safe here
    loadstring=loadstring -- functions can get serialized to text, this is required to turn them back into functions
 }

-- run code under environment [Lua 5.1]
function RunInSandbox(untrusted_code)
	if untrusted_code:byte(1) == 27 then return nil, "binary bytecode prohibited" end
	local untrusted_function, message = loadstring(untrusted_code)
	if not untrusted_function then return nil, message end
	return RunInEnvironment(untrusted_function, env)
end

function RunInEnvironment(fn, fnenv)
	setfenv(fn, fnenv)
	return xpcall(fn, debug.traceback)
end

function GetTickForTime(target_time) 
	return math.floor( target_time/GetTickTime() )
end

function GetTimeForTick(target_tick)
    return target_tick*GetTickTime()
end

function GetTaskRemaining(task)
    return (task == nil and -1)
        or (task:NextTime() == nil and -1)
        or (task:NextTime() < GetTime() and -1)
        or task:NextTime() - GetTime()
end

function GetTaskTime(task)
    return (task == nil and -1)
        or (task:NextTime() == nil and -1)
        or (task:NextTime())
end


function shuffleArray(array)
    local arrayCount = #array
    for i = arrayCount, 2, -1 do
        local j = math.random(1, i)
        array[i], array[j] = array[j], array[i]
    end
    return array
end

function shuffledKeys(dict)
	local keys = {}
	for k,v in pairs(dict) do
		table.insert(keys, k)
	end
	return shuffleArray(keys)
end

function TrackedAssert(tracking_data, function_ptr, function_data)
	--print("TrackedAssert", tracking_data, function_ptr, function_data)
	_G['tracked_assert'] = function(pass, reason)		
							--print("Tracked:Assert", tracking_data, pass, reason)	 								
			 				assert(pass, tracking_data.." --> "..reason)
			 			end
			 							
	local result = function_ptr( function_data )
					
	_G['tracked_assert'] = _G.assert
	
	return result
end

function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end


function reduce(tbl, filterfn)
	local res = {}
	for k,v in pairs(tbl) do
		if filterfn(k,v) then
			res[k] = v
		end
	end
	return tbl
end

-- if next(table) == nil, then it is empty
--
-- function IsTableEmpty(t)
-- 	local empty = true
-- 	for k,v in pairs(t) do
-- 		return false
-- 	end
-- 	return true	
-- end

function math.clamp(input, min_val, max_val)
    if input < min_val then
        input = min_val
    elseif input > max_val then
        input = max_val
    end
    return input
end

function fastdump(value)
	local tostring = tostring
	local string = string
	local table = table
	local items = {"return "}
	local type = type

	local function printtable(in_table)
		table.insert(items, "{")
		
		for k,v in pairs(in_table) do
			local t = type(v)
			local comma = true
			if type(k) == "number" then
				if t == "number" then
					table.insert(items, string.format("%s", tostring(v)))
				elseif t == "string" then
					table.insert(items, string.format("[%q]", v))
				elseif t == "boolean" then
					table.insert(items, string.format("%s", tostring(v)))
				elseif type(v) == "table" then
					printtable(v)
				end
			elseif type(k) == "string" then
				local key = tostring(k)
				if t == "number" then
					table.insert(items, string.format("%s=%s", key, tostring(v)))
				elseif t == "string" then
					table.insert(items, string.format("%s=%q", key, v))
				elseif t == "boolean" then
					table.insert(items, string.format("%s=%s", key, tostring(v)))
				elseif type(v) == "table" then
					if next(v) then
						table.insert(items, string.format("%s=", key))
						printtable(v)
					else
						comma = false
					end
				end
			else
				assert(false, "trying to save invalid data type")
			end
			if comma and next(in_table, k) then
				table.insert(items, ",")
			end
		end
		
		table.insert(items, "}")
		collectgarbage("step")
	end
	printtable(value)
	return table.concat(items)
end

--[[ Data Structures --]]

-----------------------------------------------------------------
-- Class RingBuffer (circular array)

RingBuffer = Class(function(self, maxlen)
    if type(maxlen) ~= "number" or maxlen < 1 then
        maxlen = 10
    end
    self.buffer = {}
    self.maxlen = maxlen or 10
    self.entries = 0
    self.pos = #self.buffer
end)

function RingBuffer:Clear()
    self.buffer = {}
    self.entries = 0
    self.pos = #self.buffer
end

-- Add an element to the circular buffer
function RingBuffer:Add(entry)
    local indx = self.pos % self.maxlen + 1

    self.entries = self.entries + 1
    if self.entries > self.maxlen then
        self.entries = self.maxlen
    end
    self.buffer[indx] = entry
    self.pos = indx
end

-- Access from start of circular buffer
function RingBuffer:Get(index)

    if index > self.maxlen or index > self.entries or index < 1 then
        return nil
    end

    local pos = (self.pos-self.entries) + index 
    if pos < 1 then
        pos = pos + self.entries
    end

    return self.buffer[pos]
end

function RingBuffer:GetBuffer()
    local t = {}
    for i=1, self.entries do
        t[#t+1] = self:GetElementAt(i)
    end
    return t
end

function RingBuffer:Resize(newsize)
    if type(newsize) ~= "number" or newsize < 1 then
        newsize = 1
    end

    -- not dealing with making the buffer smaller
    local nb = self:GetBuffer()

    self.buffer = nb
    self.maxlen = newsize
    self.entries = #nb
    self.pos = #nb

end

function table.setfield(Table,Name,Value)

    -- Table (table, optional); default is _G
    -- Name (string); name of the variable--e.g. A.B.C ensures the tables A
    --   and A.B and sets A.B.C to <Value>.
    --   Using single dots at the end inserts the value in the last position
    --   of the array--e.g. A. ensures table A and sets A[table.getn(A)]
    --   to <Value>.  Multiple dots are interpreted as a string--e.g. A..B.
    --   ensures the table A..B.
    -- Value (any)
    -- Compatible with Lua 5.0 and 5.1

    if type(Table) ~= 'table' then
        Table,Name,Value = _G,Table,Name
    end

    local Concat,Key = false,''

    string.gsub(Name,'([^%.]+)(%.*)',
                    function(Word,Delimiter)
                        if Delimiter == '.' then
                            if Concat then
                                Word = Key .. Word
                                Concat,Key = false,''
                            end
                            if Table == _G then -- using strict.lua have to declare global before using it
                                global(Word)
                            end
                            if type(Table[Word]) ~= 'table' then
                                Table[Word] = {}
                            end
                            Table = Table[Word]
                        else
                            Key = Key .. Word .. Delimiter
                            Concat = true
                        end
                    end
                    )

    if Key == '' then
        Table[#Table+1] = Value
    else
        Table[Key] = Value
    end

end


function table.getfield(Table,Name)
    -- Access a value in a table using a string
    -- table.getfield(A,"A.b.c.foo.bar")

    if type(Table) ~= 'table' then
        Table,Name = _G,Table
    end

    for w in string.gfind(Name, "[%w_]+") do
        Table = Table[w]
        if Table == nil then
            return nil
        end
    end
    return Table
end

function table.findfield(Table,Name)
    local indx = ""

    for i,v in pairs(Table) do
        if i == Name then
            return i
        end
        if type(v) == "table" then
            indx = table.findfield(v,Name)
            if indx then
                return i .. "." .. indx
            end
        end
    end
    return nil
end

function table.findpath(Table,Names,indx)
    local path = ""
    indx = indx or 1
    if type(Names) == "string" then
        Names = {Names}
    end

    for i,v in pairs(Table) do
        if i == Names[indx] then
            if indx == #Names then
                return i
            elseif type(v) == "table" then
                path = table.findpath(v,Names,indx+1)
                if path then
                    return i .. "." .. path
                else
                    return nil
                end
            end
        end
        if type(v) == "table" then
            path = table.findpath(v,Names,indx)
            if path then
                return i .. "." .. path
            end
        end
    end
    return nil
end

function TrackMem()
	collectgarbage()
	collectgarbage("stop")
	TheSim:SetMemoryTracking(true)
end

function DumpMem()
	TheSim:DumpMemoryStats()
	mem_report()
	collectgarbage("restart")
	TheSim:SetMemoryTracking(false)
end
