table.inspect = require("inspect")   -- add table pretty printer that understands recursive tables

local getinfo = debug.getinfo
local max = math.max
local concat = table.concat

local function filtersource(src)
        if not src then return "[?]" end
        if src:sub(1, 1) == "@" then
                src = src:sub(2)
        end
        return src
end

local function formatinfo(info)
        if not info then return "**error**" end
        local source = filtersource(info.source)
        if info.currentline then
                source = source..":"..info.currentline
        end
        return ("\t%s in (%s) %s (%s) <%d-%d>"):format(source, info.namewhat, info.name or "?", info.what, info.linedefined, info.lastlinedefined)
end

function debugstack(start, top, bottom)
        if not bottom then bottom = 10 end
        if not top then top = 12 end
        start = (start or 1) + 1

        local count = max(2, start)
        while getinfo(count) do
                count = count + 1
        end

        count = count - start

        if top + bottom >= count then
                top = count
                bottom = nil
        end

        local s = {"stack traceback:"}
        for i = 1, top, 1 do
                s[#s + 1] = formatinfo(getinfo(start + i - 1))
        end
        if bottom then
                s[#s + 1] = "\t..."
                for i = bottom , 1, -1 do
                        s[#s + 1] = formatinfo(getinfo(count - i + 1))
                end
        end

        return concat(s, "\n")
end

function debuglocals (level)
        local t = {}
        local index = 1
        while true do
                local name, value = debug.getlocal(level + 1, index)
                if not name then break end
                t[index] = string.format("%s = %s", name, tostring(value))
                index = index + 1
        end
        return table.concat(t, "\n")
end

function dumptable(obj, indent, recurse_levels)
	indent = indent or 1
	local i_recurse_levels = recurse_levels or 10
    if obj then
		local dent = ""
		if indent then
			for i=1,indent do dent = dent.."\t" end
		end
    	if type(obj)==type("") then
    		print(obj)
    		return
    	end
        for k,v in pairs(obj) do
            if type(v) == "table" and i_recurse_levels>0 then
                print(dent.."K: ",k)
                dumptable(v, indent+1, i_recurse_levels-1)
            else
                print(dent.."K: ",k," V: ",v)
            end
        end
    end
end

function tabletodictstring(obj, fn)
	if obj == nil then
		return "{ }"
	end
	local s = "{ "
	local first = true
	for k,v in pairs(obj) do
		if not first then 
			s = s..", "
		else
			first = false
		end
		if fn then k,v = fn(k,v) end
		s = s..tostring(k).."="..tostring(v)
	end
	s = s.." }"
	return s
end
function tabletoliststring(obj, fn)
	if obj == nil then
		return "[ ]"
	end
	local s = "[ "
	local first = true
	for i,v in ipairs(obj) do
		if not first then 
			s = s..", "
		else
			first = false
		end
		if fn then v = fn(v) end
		s = s..tostring(v)
	end
	s = s.." ]"
	return s
end


--[[
    Better control over IO
--]]

global("CWD")
local userName = ""
local dir = CWD or ""
dir = string.gsub(dir, "\\", "/")

-- Copied from scheduler.lua - puts tabs between items and LuaPrint adds a \n at the end
local function oldprint(...)
        local str = ''
        local arg = {n=select('#',...),...}
     
        for i = 1, arg.n do
            if str ~= '' then str = str .. '\t' end
            str = str .. tostring( arg[i] )
        end
     
        --str = str .. '\n'
     
        TheSim:LuaPrint( str )
end


-- Output directly to stdout after conversion to string representation - no extra cruft
local function DirectIO(...)
    local arg = {n=select('#',...),...}
 
    for i = 1, arg.n do
        io.stdout:write( tostring( arg[i] ) )
    end
end


--[[
   Fast way to disable all the spew to the console window by defining a few globals (yes, setting these should probably be functions)
   Will not output if:
        CHEATS_ENABLE_DPRINT is false
   If DPRINT_USERNAME is defined, then will only print if this equals the string returned by TheSim:GetUsersName()
   if DPRINT_PRINT_SOURCELINE is true, acts like print and outputs calling file and line number
--]]
    

function dprint(...)
    global("CHEATS_ENABLE_DPRINT")
    global("DPRINT_PRINT_SOURCELINE")
    global("DPRINT_USERNAME")

    if not (CHEATS_ENABLED and CHEATS_ENABLE_DPRINT) then
        return
    end

    if DPRINT_USERNAME then
        if type(TheSim.GetUsersName) == "function" then 
            userName = TheSim:GetUsersName()
        end
        if userName ~= DPRINT_USERNAME then
            return
        end
    end

    if DPRINT_PRINT_SOURCELINE then
        local info = debug.getinfo(2, "Sl")
        local source = info.source
        if info.source and string.sub(info.source,1,1)=="@" then
            source = source:sub(2)
        end
        local defline = string.format("%s(%d,1)", tostring(source), info.currentline)
        oldprint(defline, ...)
    else
        oldprint(...)
    end
end

-- Raw characters to stdout without processing
function IOprint(...)
    global("CHEATS_ENABLE_DPRINT")
    global("DPRINT_USERNAME")

    if not (CHEATS_ENABLED and CHEATS_ENABLE_DPRINT) then
        return
    end

    if DPRINT_USERNAME then
        if type(TheSim.GetUsersName) == "function" then 
            userName = TheSim:GetUsersName()
        end
        if userName ~= DPRINT_USERNAME then
            return
        end
    end
    DirectIO(...)
end

-- Only print if inst is debugentity
function eprint(inst,...)
    if inst == GetDebugEntity() then
        dprint(...)
    end
end

-- Add debug hook to any object:  Author DForsey
-- Usage:  
--      EnableDebugOnEntity(thing)              turns on all debug printing for this thing (same as calling with (thing,"all") )
--      EnableDebugOnEntity(thing,false)        turns off all debug printing for this thing, resets all items and/or priority
--      EnableDebugOnEntity(thing,number)       turns on debug printing for requests with priority<number
--      EnableDebugOnEntity(thing,"string")     turns on debug printing only for requests tagged with "string"
--      EnableDebugOnEntity(thing,"off")        turns off debug printing, but doesn't reset the tag list or priority
--      EnableDebugOnEntity(thing,"on")         turns on debug printing without affecting priority or tag list
--      EnableDebugOnEntity(thing,"all")        all Dbg calls will print
--
--      Dbg(thing,true,...)                     prints arg list if debug print is enabled for this thing
--      Dbg(thing,number,...)                   prints arg list with the given priority level
--      Dbg(thing,"string",...)                 prints arg list if "string" has been tagged for this thing
--

function Dbg(thing,level,...)
    if not thing._DEBUG_List or not thing._DEBUG_List.on or not CHEATS_ENABLED then return end

    thing._DEBUG_List.priority = thing._DEBUG_List.priority or 0

    if type(level) == "string" and thing._DEBUG_List[level] then
        oldprint(...)
    elseif type(level) == "number" and thing._DEBUG_List.priority < level then
        oldprint(...)
    elseif thing._DEBUG_List["all"] then
        oldprint(...)
    end
end

function EnableDebugOnEntity(thing,items)

    if type(thing) ~= "table" then return end

    thing._DEBUG_List = thing._DEBUG_List or {on=true}

    if items == false then
        thing._DEBUG_List = {on=false}
        return
    elseif items == "on" then
        thing._DEBUG_List = {on=true}
    elseif items == "off" then
        thing._DEBUG_List = {on=false}
    end

    if type(items) == string then
        thing._DEBUG_List[items] = true
        thing._DEBUG_List.on = true
    elseif type(items) == "number" then
        thing._DEBUG_List.priority = items
    else
        thing._DEBUG_List["all"] = true
        thing._DEBUG_List.on = true
    end
end

function ddump(obj, indent, recurse_levels, root)
	indent = indent or 1
	local i_recurse_levels = recurse_levels or 3
    if obj then
		local dent = ""
		if indent then
			for i=1,indent do dent = dent.." " end
		end
    	if type(obj)==type("") then
    		dprint(obj)
    		return
    	end
        for k,v in pairs(obj) do
            if v and v == root then
                dprint(dent.."K: <SELF>")
                return
            end
            if type(v) == "table" and i_recurse_levels>0 then
                dprint(dent.."K: ",k)
                root = root or obj
                ddump(v, indent+1, i_recurse_levels-1,root)
            else
                dprint(dent.."K: ",k," V: ",v)
            end
        end
    end
end

function dtable( tab, depth )
    if type(tab) ~= "table" then
        dprint(tab)
    elseif table.inspect then
        depth = depth or 1
        dprint(table.inspect(tab,depth))
    end
end


function DrawLine(pos1,pos2)
	-- debug draw of new map gen
	local debugdrawmap = CreateEntity()
	local draw = debugdrawmap.entity:AddDebugRender()
	draw:SetZ(0.1)
	draw:Line(pos1.x, pos1.z, pos2.x,pos2.y, 255, 255, 255, 255)
    draw:Flush()
	
--[[	
	for idx,node in ipairs(graph.nodes) do
		local colour = graph.colours[node.c]
		
		for i =1, #node.poly-1 do
			draw:Line(node.poly[i][1], node.poly[i][2], node.poly[i+1][1], node.poly[i+1][2], colour.r, colour.g, colour.b, 255)
		end
		draw:Line(node.poly[1][1], node.poly[1][2], node.poly[#node.poly][1], node.poly[#node.poly][2], colour.r, colour.g, colour.b, 255)
		
		draw:Poly(node.cent[1], node.cent[2], colour.r, colour.g, colour.b, colour.a, node.poly)
			
		draw:String(graph.ids[idx].."("..node.cent[1]..","..node.cent[2]..")", 	node.cent[1], node.cent[2], node.ts)
	end 
	
	draw:SetZ(0.15)

	for idx,edge in ipairs(graph.edges) do
		if edge.n1 ~= nil and edge.n2 ~= nil then
			local colour = graph.colours[edge.c]
			
			local n1 = graph.nodes[edge.n1]
			local n2 = graph.nodes[edge.n2]
			if n1 ~= nil and n2 ~= nil then
				draw:Line(n1.cent[1], n1.cent[2], n2.cent[1], n2.cent[2], colour.r, colour.g, colour.b, colour.a)
			end
		end
	end 
--]]
end

